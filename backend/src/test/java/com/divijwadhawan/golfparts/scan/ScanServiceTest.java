package com.divijwadhawan.golfparts.scan;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import com.divijwadhawan.golfparts.catalog.Assembly;
import com.divijwadhawan.golfparts.catalog.AssemblyRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

class ScanServiceTest {

    @Mock
    private ImageAnalysisProvider imageAnalysisProvider;

    @Mock
    private AssemblyRepository assemblyRepository;

    @Mock
    private ScanRepository scanRepository;

    private ScanService scanService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        scanService = new ScanService(
                imageAnalysisProvider,
                assemblyRepository,
                scanRepository
        );
    }

    @Test
    void successfulScanShouldBeSaved() {

        ScanResult geminiResult = new ScanResult(
                "FRONT_BUMPER",
                0.95,
                new ScanResult.BoundingBox(
                        0.27,
                        0.65,
                        0.46,
                        0.11
                )
        );

        when(imageAnalysisProvider.analyze(
                any(byte[].class),
                eq("image/jpeg")
        )).thenReturn(geminiResult);

        Assembly assembly = new Assembly(
                "FRONT_BUMPER",
                "Front Bumper",
                "Front bumper assembly",
                "front_bumper"
        );

        when(assemblyRepository.findByCode("FRONT_BUMPER"))
                .thenReturn(Optional.of(assembly));

        ScanResult result = scanService.analyzeImage(
                new byte[]{1, 2, 3},
                "image/jpeg",
                "test-google-user"
        );

        assertEquals(
                "FRONT_BUMPER",
                result.assemblyCode()
        );

        assertEquals(
                0.95,
                result.confidence()
        );

        verify(scanRepository)
                .save(any(Scan.class));
    }

    @Test
    void unknownScanShouldNotBeSaved() {

        ScanResult geminiResult = new ScanResult(
                "UNKNOWN",
                0.40,
                new ScanResult.BoundingBox(
                        0.0,
                        0.0,
                        0.0,
                        0.0
                )
        );

        when(imageAnalysisProvider.analyze(
                any(byte[].class),
                eq("image/jpeg")
        )).thenReturn(geminiResult);

        ScanResult result = scanService.analyzeImage(
                new byte[]{1, 2, 3},
                "image/jpeg",
                "test-google-user"
        );

        assertEquals(
                "UNKNOWN",
                result.assemblyCode()
        );

        verify(
                scanRepository,
                never()
        ).save(any(Scan.class));
    }

    @Test
    void nonexistentAssemblyShouldNotBeSaved() {

        ScanResult geminiResult = new ScanResult(
                "WHEEL",
                0.90,
                new ScanResult.BoundingBox(
                        0.20,
                        0.30,
                        0.40,
                        0.50
                )
        );

        when(imageAnalysisProvider.analyze(
                any(byte[].class),
                eq("image/jpeg")
        )).thenReturn(geminiResult);

        when(assemblyRepository.findByCode("WHEEL"))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> scanService.analyzeImage(
                        new byte[]{1, 2, 3},
                        "image/jpeg",
                        "test-google-user"
                )
        );

        verify(
                scanRepository,
                never()
        ).save(any(Scan.class));
    }

    @Test
    void unsupportedImageTypeShouldBeRejected() {

        assertThrows(
                IllegalArgumentException.class,
                () -> scanService.analyzeImage(
                        new byte[]{1, 2, 3},
                        "application/pdf",
                        "test-google-user"
                )
        );

        verify(
                imageAnalysisProvider,
                never()
        ).analyze(
                any(byte[].class),
                any(String.class)
        );

        verify(
                scanRepository,
                never()
        ).save(any(Scan.class));
    }

    @Test
    void emptyImageShouldBeRejected() {

        assertThrows(
                IllegalArgumentException.class,
                () -> scanService.analyzeImage(
                        new byte[]{},
                        "image/jpeg",
                        "test-google-user"
                )
        );

        verify(
                imageAnalysisProvider,
                never()
        ).analyze(
                any(byte[].class),
                any(String.class)
        );
    }
}