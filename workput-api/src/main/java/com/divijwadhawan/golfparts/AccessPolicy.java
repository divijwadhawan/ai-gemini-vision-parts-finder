package com.example.workout_api;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

@Component
public class AccessPolicy {
    private final AccessRequestRepository requests;
    private final String adminSub;

    public AccessPolicy(AccessRequestRepository requests,
                        @Value("${APP_ADMIN_SUB:}") String adminSub) {
        this.requests = requests;
        this.adminSub = adminSub;
    }

    public boolean isAdmin(Authentication authentication) {
        return authentication instanceof JwtAuthenticationToken jwt
                && !adminSub.isBlank()
                && adminSub.equals(jwt.getToken().getSubject());
    }

    public boolean canReadParts(Authentication authentication) {
        if (!(authentication instanceof JwtAuthenticationToken jwt)) {
            return false;
        }
        if (isAdmin(authentication)) {
            return true;
        }
        return requests.findByGoogleSub(jwt.getToken().getSubject())
                .map(request -> request.getStatus() == AccessRequest.Status.APPROVED)
                .orElse(false);
    }
}
