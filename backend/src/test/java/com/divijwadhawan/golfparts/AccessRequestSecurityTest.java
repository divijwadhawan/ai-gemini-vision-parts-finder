package com.divijwadhawan.golfparts;

import com.divijwadhawan.golfparts.auth.AccessRequest;
import com.divijwadhawan.golfparts.auth.AccessRequestRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;


/**
 * Integration tests for the GolfParts access approval flow.
 *
 * Tests:
 *
 * 1. A new authenticated user has NOT_REQUESTED status.
 * 2. A user can request access and becomes PENDING.
 * 3. A normal user cannot access admin endpoints.
 * 4. The configured admin is automatically APPROVED.
 * 5. The admin can list access requests.
 * 6. The admin can approve a pending request.
 * 7. The admin can reject a pending request.
 */
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "APP_ADMIN_SUB=admin-test-sub"
})
class AccessRequestSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AccessRequestRepository requests;


    /**
     * Start every test with an empty access_requests table.
     *
     * This makes each test independent from the others.
     */
    @BeforeEach
    void cleanDatabase() {
        requests.deleteAll();
    }


    /**
     * A Google user who has never requested access should
     * receive NOT_REQUESTED.
     */
    @Test
    void newUserShouldHaveNotRequestedStatus()
            throws Exception {

        mockMvc.perform(
                get("/access-requests/me")
                        .with(jwt().jwt(jwt ->
                                jwt.subject("new-user")
                        ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.status")
                        .value("NOT_REQUESTED")
        );
    }


    /**
     * An authenticated Google user should be able to create
     * an access request.
     */
    @Test
    void userCanRequestAccess()
            throws Exception {

        mockMvc.perform(
                post("/access-requests")
                        .with(jwt().jwt(jwt -> jwt
                                .subject("new-user")
                                .claim(
                                        "email",
                                        "new@example.com"
                                )
                                .claim(
                                        "email_verified",
                                        true
                                )
                        ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.status")
                        .value("PENDING")
        );


        // Verify that the request was actually stored.
        AccessRequest request =
                requests
                        .findByGoogleSub("new-user")
                        .orElseThrow();

        assert request.getStatus()
                == AccessRequest.Status.PENDING;
    }


    /**
     * A normal authenticated user must NOT be able to use
     * the admin API.
     */
    @Test
    void normalUserCannotAccessAdminEndpoints()
            throws Exception {

        mockMvc.perform(
                get("/admin/access-requests")
                        .with(jwt().jwt(jwt ->
                                jwt.subject("normal-user")
                        ))
        )
        .andExpect(status().isForbidden());
    }


    /**
     * The configured application administrator does not need
     * to submit an access request.
     *
     * The backend should always report APPROVED.
     */
    @Test
    void adminShouldAutomaticallyBeApproved()
            throws Exception {

        mockMvc.perform(
                get("/access-requests/me")
                        .with(jwt().jwt(jwt ->
                                jwt.subject("admin-test-sub")
                        ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.status")
                        .value("APPROVED")
        );
    }


    /**
     * The admin should be able to see submitted requests.
     */
    @Test
    void adminCanListAccessRequests()
            throws Exception {

        requests.save(
                new AccessRequest(
                        "pending-user",
                        "pending@example.com"
                )
        );


        mockMvc.perform(
                get("/admin/access-requests")
                        .with(jwt().jwt(jwt ->
                                jwt.subject("admin-test-sub")
                        ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$[0].googleSub")
                        .value("pending-user")
        )
        .andExpect(
                jsonPath("$[0].status")
                        .value("PENDING")
        );
    }


    /**
     * The admin should be able to approve a pending request.
     */
    @Test
    void adminCanApproveRequest()
            throws Exception {

        AccessRequest request =
                requests.save(
                        new AccessRequest(
                                "pending-user",
                                "pending@example.com"
                        )
                );


        mockMvc.perform(
                post(
                        "/admin/access-requests/"
                                + request.getId()
                                + "/approve"
                )
                .with(jwt().jwt(jwt ->
                        jwt.subject("admin-test-sub")
                ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.status")
                        .value("APPROVED")
        );


        AccessRequest approved =
                requests
                        .findById(
                                request.getId()
                        )
                        .orElseThrow();


        assert approved.getStatus()
                == AccessRequest.Status.APPROVED;
    }


    /**
     * The admin should also be able to reject a request.
     */
    @Test
    void adminCanRejectRequest()
            throws Exception {

        AccessRequest request =
                requests.save(
                        new AccessRequest(
                                "pending-user",
                                "pending@example.com"
                        )
                );


        mockMvc.perform(
                post(
                        "/admin/access-requests/"
                                + request.getId()
                                + "/reject"
                )
                .with(jwt().jwt(jwt ->
                        jwt.subject("admin-test-sub")
                ))
        )
        .andExpect(status().isOk())
        .andExpect(
                jsonPath("$.status")
                        .value("REJECTED")
        );


        AccessRequest rejected =
                requests
                        .findById(
                                request.getId()
                        )
                        .orElseThrow();


        assert rejected.getStatus()
                == AccessRequest.Status.REJECTED;
    }
}