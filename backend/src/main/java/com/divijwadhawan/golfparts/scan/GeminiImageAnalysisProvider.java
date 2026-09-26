package com.divijwadhawan.golfparts.scan;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Base64;
import java.util.Set;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@Component
public class GeminiImageAnalysisProvider implements ImageAnalysisProvider {

    private static final Set<String> ALLOWED_ASSEMBLIES = Set.of(
            "FRONT_BUMPER",
            "ENGINE",
            "REAR_BUMPER",
            "SIDE_MIRROR",
            "DOOR",
            "UNKNOWN"
    );

    private static final int MAX_ATTEMPTS = 2;

    private final String apiKey;
    private final HttpClient httpClient;
    private final JsonMapper jsonMapper;

    public GeminiImageAnalysisProvider(
            @Value("${gemini.api.key}") String apiKey,
            JsonMapper jsonMapper
    ) {
        this.apiKey = apiKey;

        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();

        this.jsonMapper = jsonMapper;
    }

    @Override
    public ScanResult analyze(
            byte[] image,
            String mimeType
    ) {
        try {
            String base64Image =
                    Base64.getEncoder().encodeToString(image);

            String requestBody = """
                    {
                      "contents": [{
                        "parts": [
                          {
                            "text": "Analyze this Volkswagen Golf 7 image. Identify the main visible assembly. If none of the allowed assemblies can be confidently identified, return UNKNOWN. Detect the bounding box of the identified assembly. Bounding box coordinates use the Gemini 0-1000 coordinate system."
                          },
                          {
                            "inline_data": {
                              "mime_type": "%s",
                              "data": "%s"
                            }
                          }
                        ]
                      }],
                      "generationConfig": {
                        "responseMimeType": "application/json",
                        "responseSchema": {
                          "type": "object",
                          "properties": {
                            "assemblyCode": {
                              "type": "string",
                              "enum": [
                                "FRONT_BUMPER",
                                "ENGINE",
                                "REAR_BUMPER",
                                "SIDE_MIRROR",
                                "DOOR",
                                "UNKNOWN"
                              ]
                            },
                            "confidence": {
                              "type": "number",
                              "minimum": 0,
                              "maximum": 1
                            },
                            "x": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000
                            },
                            "y": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000
                            },
                            "width": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000
                            },
                            "height": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 1000
                            }
                          },
                          "required": [
                            "assemblyCode",
                            "confidence",
                            "x",
                            "y",
                            "width",
                            "height"
                          ]
                        }
                      }
                    }
                    """.formatted(
                            mimeType,
                            base64Image
                    );

            HttpResponse<String> response =
                    sendWithRetry(requestBody);

            JsonNode root =
                    jsonMapper.readTree(response.body());

            String geminiText = root
                    .path("candidates")
                    .path(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text")
                    .asText();

            if (geminiText.isBlank()) {
                throw new RuntimeException(
                        "Gemini returned an empty response"
                );
            }

            GeminiAnalysisResponse analysis =
                    jsonMapper.readValue(
                            geminiText,
                            GeminiAnalysisResponse.class
                    );

            if (!ALLOWED_ASSEMBLIES.contains(
                    analysis.assemblyCode())) {

                throw new RuntimeException(
                        "Unexpected assembly code: "
                                + analysis.assemblyCode()
                );
            }

            double x = analysis.x() / 1000.0;
            double y = analysis.y() / 1000.0;
            double width = analysis.width() / 1000.0;
            double height = analysis.height() / 1000.0;

            return new ScanResult(
                    analysis.assemblyCode(),
                    analysis.confidence(),
                    new ScanResult.BoundingBox(
                            x,
                            y,
                            width,
                            height
                    )
            );

        } catch (Exception e) {
            throw new RuntimeException(
                    "Gemini image analysis failed",
                    e
            );
        }
    }

    private HttpResponse<String> sendWithRetry(
            String requestBody
    ) throws Exception {

        for (int attempt = 1;
             attempt <= MAX_ATTEMPTS;
             attempt++) {

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(
                            "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent"
                    ))
                    .header("x-goog-api-key", apiKey)
                    .header(
                            "Content-Type",
                            "application/json"
                    )
                    .timeout(Duration.ofSeconds(20))
                    .POST(
                            HttpRequest.BodyPublishers
                                    .ofString(requestBody)
                    )
                    .build();

            HttpResponse<String> response =
                    httpClient.send(
                            request,
                            HttpResponse.BodyHandlers.ofString()
                    );

            int status = response.statusCode();

            if (status == 200) {
                return response;
            }

            boolean retryable =
                    status == 429 || status == 503;

            if (retryable && attempt < MAX_ATTEMPTS) {

                Thread.sleep(500);

                continue;
            }

            throw new RuntimeException(
                    "Gemini returned HTTP "
                            + status
                            + ": "
                            + response.body()
            );
        }

        throw new RuntimeException(
                "Gemini request failed"
        );
    }
}