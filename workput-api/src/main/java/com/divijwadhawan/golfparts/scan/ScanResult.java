package com.divijwadhawan.golfparts.scan;

public record ScanResult(
        String assemblyCode,
        double confidence,
        BoundingBox boundingBox
) {

    public record BoundingBox(
            double x,
            double y,
            double width,
            double height
    ) {}
}