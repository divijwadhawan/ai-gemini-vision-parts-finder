package com.divijwadhawan.golfparts.scan;

import java.time.Instant;

public record ScanResponse(
        Long id,
        String assemblyCode,
        double confidence,
        double boundingBoxX,
        double boundingBoxY,
        double boundingBoxWidth,
        double boundingBoxHeight,
        Instant createdAt
) {
}