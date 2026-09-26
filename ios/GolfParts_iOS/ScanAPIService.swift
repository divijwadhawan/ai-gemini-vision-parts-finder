import Foundation

enum ScanAPIError: LocalizedError {

    case invalidResponse
    case serverError(Int, String)

    var errorDescription: String? {

        switch self {

        case .invalidResponse:
            return "Invalid response from the GolfParts API."

        case .serverError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        }
    }
}

final class ScanAPIService {

    private let baseURL =
        "https://api.divijwadhawan.com"

    func scanImage(
        imageData: Data,
        mimeType: String = "image/jpeg",
        idToken: String
    ) async throws -> ScanResult {

        guard let url = URL(
            string: "\(baseURL)/scan"
        ) else {
            throw ScanAPIError.invalidResponse
        }

        let boundary =
            "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "Bearer \(idToken)",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.append(
            "--\(boundary)\r\n"
                .data(using: .utf8)!
        )

        body.append(
            """
            Content-Disposition: form-data; name="image"; filename="golf.jpg"\r\n
            """
            .data(using: .utf8)!
        )

        body.append(
            "Content-Type: \(mimeType)\r\n\r\n"
                .data(using: .utf8)!
        )

        body.append(imageData)

        body.append(
            "\r\n--\(boundary)--\r\n"
                .data(using: .utf8)!
        )

        request.httpBody = body

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw ScanAPIError.invalidResponse
        }

        let responseBody =
            String(
                data: data,
                encoding: .utf8
            ) ?? ""

        print(
            "SCAN API HTTP:",
            httpResponse.statusCode
        )

        print(
            "SCAN API RESPONSE:",
            responseBody
        )

        guard (200...299).contains(
            httpResponse.statusCode
        ) else {

            throw ScanAPIError.serverError(
                httpResponse.statusCode,
                responseBody
            )
        }

        return try JSONDecoder().decode(
            ScanResult.self,
            from: data
        )
    }
}
