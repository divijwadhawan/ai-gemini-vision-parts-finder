package com.divijwadhawan.golfparts.scan;

public interface ImageAnalysisProvider {

    ScanResult analyze(
            byte[] image,
            String mimeType
    );
}