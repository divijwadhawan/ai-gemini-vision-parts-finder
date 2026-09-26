package com.divijwadhawan.golfparts.scan;

import java.io.IOException;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class ScanController {

    private final ScanService scanService;
    private final ScanRateLimiter scanRateLimiter;

    public ScanController(
            ScanService scanService,
            ScanRateLimiter scanRateLimiter
    ) {
        this.scanService = scanService;
        this.scanRateLimiter = scanRateLimiter;
    }

    @PostMapping(
            value = "/scan",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ScanResult scan(
            @RequestPart("image") MultipartFile image,
            JwtAuthenticationToken authentication
    ) throws IOException {

        String googleSub =
                authentication.getToken().getSubject();

        if (!scanRateLimiter.allow(googleSub)) {
            throw new ResponseStatusException(
                    HttpStatus.TOO_MANY_REQUESTS,
                    "Maximum 5 scans per minute allowed"
            );
        }

        String mimeType =
                image.getContentType();

        return scanService.analyzeImage(
                image.getBytes(),
                mimeType,
                googleSub
        );
    }

    @GetMapping("/scans/me")
    public List<ScanResponse> getMyScans(
            JwtAuthenticationToken authentication
    ) {

        String googleSub =
                authentication.getToken().getSubject();

        return scanService.getScansForUser(
                googleSub
        );
    }
}