package com.divijwadhawan.golfparts.scan;

public record GeminiAnalysisResponse(
        String assemblyCode,
        double confidence,
        int x,
        int y,
        int width,
        int height
) {}