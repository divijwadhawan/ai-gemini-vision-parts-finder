package com.divijwadhawan.golfparts.scan;

import java.util.List;
import java.util.Set;

import com.divijwadhawan.golfparts.catalog.AssemblyRepository;
import org.springframework.stereotype.Service;

@Service
public class ScanService {

    private static final Set<String> ALLOWED_MIME_TYPES = Set.of(
            "image/jpeg",
            "image/png"
    );

    private static final int MAX_IMAGE_SIZE =
            10 * 1024 * 1024; // 10 MB

    private final ImageAnalysisProvider imageAnalysisProvider;
    private final AssemblyRepository assemblyRepository;
    private final ScanRepository scanRepository;

    public ScanService(
            ImageAnalysisProvider imageAnalysisProvider,
            AssemblyRepository assemblyRepository,
            ScanRepository scanRepository
    ) {
        this.imageAnalysisProvider = imageAnalysisProvider;
        this.assemblyRepository = assemblyRepository;
        this.scanRepository = scanRepository;
    }

    public ScanResult analyzeImage(
            byte[] image,
            String mimeType,
            String googleSub
    ) {
        validateImage(image, mimeType);

        ScanResult result =
                imageAnalysisProvider.analyze(
                        image,
                        mimeType
                );

        if ("UNKNOWN".equals(result.assemblyCode())) {
            return result;
        }

        boolean assemblyExists =
                assemblyRepository
                        .findByCode(result.assemblyCode())
                        .isPresent();

        if (!assemblyExists) {
            throw new IllegalStateException(
                    "Detected assembly does not exist in the catalog: "
                            + result.assemblyCode()
            );
        }

        ScanResult.BoundingBox box =
                result.boundingBox();

        Scan scan = new Scan(
                googleSub,
                result.assemblyCode(),
                result.confidence(),
                box.x(),
                box.y(),
                box.width(),
                box.height()
        );

        scanRepository.save(scan);

        return result;
    }

    public List<ScanResponse> getScansForUser(
            String googleSub
    ) {
        return scanRepository
                .findByGoogleSubOrderByCreatedAtDesc(
                        googleSub
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private void validateImage(
            byte[] image,
            String mimeType
    ) {
        if (image == null || image.length == 0) {
            throw new IllegalArgumentException(
                    "Image must not be empty"
            );
        }

        if (mimeType == null
                || !ALLOWED_MIME_TYPES.contains(mimeType)) {

            throw new IllegalArgumentException(
                    "Only JPEG and PNG images are supported"
            );
        }

        if (image.length > MAX_IMAGE_SIZE) {
            throw new IllegalArgumentException(
                    "Image must not exceed 10 MB"
            );
        }
    }

    private ScanResponse toResponse(Scan scan) {
        return new ScanResponse(
                scan.getId(),
                scan.getAssemblyCode(),
                scan.getConfidence(),
                scan.getBoundingBoxX(),
                scan.getBoundingBoxY(),
                scan.getBoundingBoxWidth(),
                scan.getBoundingBoxHeight(),
                scan.getCreatedAt()
        );
    }
}