package com.divijwadhawan.golfparts;

import com.divijwadhawan.golfparts.auth.AccessPolicy;
import com.divijwadhawan.golfparts.scan.ScanRateLimiter;
import com.divijwadhawan.golfparts.scan.ScanResult;
import com.divijwadhawan.golfparts.scan.ScanService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class ScanSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ScanService scanService;

    @MockitoBean
    private AccessPolicy accessPolicy;

    @MockitoBean
    private ScanRateLimiter scanRateLimiter;

    private MockMultipartFile createTestImage() {
        return new MockMultipartFile(
                "image",
                "golf.jpg",
                "image/jpeg",
                "fake-image".getBytes()
        );
    }

    @Test
    void scanWithoutAuthenticationShouldReturn401()
            throws Exception {

        mockMvc.perform(
                multipart("/scan")
                        .file(createTestImage())
        )
        .andExpect(status().isUnauthorized());
    }

    @Test
    void pendingUserShouldReturn403()
            throws Exception {

        when(accessPolicy.canReadParts(any()))
                .thenReturn(false);

        mockMvc.perform(
                multipart("/scan")
                        .file(createTestImage())
                        .with(jwt().jwt(jwt ->
                                jwt.subject("pending-user")
                        ))
        )
        .andExpect(status().isForbidden());
    }

    @Test
    void approvedUserShouldBeAllowedToScan()
            throws Exception {

        when(accessPolicy.canReadParts(any()))
                .thenReturn(true);

        when(scanRateLimiter.allow("approved-user"))
                .thenReturn(true);

        ScanResult result = new ScanResult(
                "FRONT_BUMPER",
                0.95,
                new ScanResult.BoundingBox(
                        0.27,
                        0.65,
                        0.46,
                        0.11
                )
        );

        when(scanService.analyzeImage(
                any(byte[].class),
                eq("image/jpeg"),
                eq("approved-user")
        )).thenReturn(result);

        mockMvc.perform(
                multipart("/scan")
                        .file(createTestImage())
                        .with(jwt().jwt(jwt ->
                                jwt.subject("approved-user")
                        ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.assemblyCode")
                        .value("FRONT_BUMPER")
        )
        .andExpect(
                jsonPath("$.confidence")
                        .value(0.95)
        );
    }

    @Test
    void sixthScanShouldReturn429()
            throws Exception {

        when(accessPolicy.canReadParts(any()))
                .thenReturn(true);

        when(scanRateLimiter.allow("approved-user"))
                .thenReturn(false);

        mockMvc.perform(
                multipart("/scan")
                        .file(createTestImage())
                        .with(jwt().jwt(jwt ->
                                jwt.subject("approved-user")
                        ))
        )
        .andExpect(status().isTooManyRequests());
    }
}