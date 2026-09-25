package com.divijwadhawan.golfparts.scan;

// import org.springframework.stereotype.Component;

// @Component
public class MockImageAnalysisProvider implements ImageAnalysisProvider {

    @Override
    public ScanResult analyze(
            byte[] image,
            String mimeType
    ) {
        return new ScanResult(
                "FRONT_BUMPER",
                0.95,
                new ScanResult.BoundingBox(
                        0.10,
                        0.30,
                        0.80,
                        0.35
                )
        );
    }
}