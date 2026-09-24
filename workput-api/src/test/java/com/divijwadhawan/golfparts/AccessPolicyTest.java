package com.divijwadhawan.golfparts;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;

import com.divijwadhawan.golfparts.auth.AccessPolicy;
import com.divijwadhawan.golfparts.auth.AccessRequest;
import com.divijwadhawan.golfparts.auth.AccessRequestRepository;

class AccessPolicyTest {
    private final AccessRequestRepository requests = mock(AccessRequestRepository.class);
    private final AccessPolicy policy = new AccessPolicy(requests, "owner-sub");

    private JwtAuthenticationToken googleUser(String sub) {
        Jwt jwt = Jwt.withTokenValue("test")
                .header("alg", "RS256")
                .claim("sub", sub)
                .build();
        return new JwtAuthenticationToken(jwt);
    }

    @Test
    void onlyOwnerOrApprovedUserCanReadParts() {
        AccessRequest pending = new AccessRequest("pending-sub", "pending@example.com");
        AccessRequest approved = new AccessRequest("approved-sub", "approved@example.com");
        approved.approve("owner-sub");
        when(requests.findByGoogleSub("pending-sub")).thenReturn(Optional.of(pending));
        when(requests.findByGoogleSub("approved-sub")).thenReturn(Optional.of(approved));
        when(requests.findByGoogleSub("unknown-sub")).thenReturn(Optional.empty());

        assertTrue(policy.canReadParts(googleUser("owner-sub")));
        assertTrue(policy.canReadParts(googleUser("approved-sub")));
        assertFalse(policy.canReadParts(googleUser("pending-sub")));
        assertFalse(policy.canReadParts(googleUser("unknown-sub")));
        assertFalse(policy.canReadParts(new AnonymousAuthenticationToken(
                "key", "anonymousUser", AuthorityUtils.createAuthorityList("ROLE_ANONYMOUS"))));
    }

    @Test
    void missingAdminConfigurationDoesNotGrantAdminAccess() {
        AccessPolicy unconfigured = new AccessPolicy(requests, "");
        assertFalse(unconfigured.isAdmin(googleUser("owner-sub")));
    }
}
