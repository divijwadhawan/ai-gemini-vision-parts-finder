package com.example.workout_api;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class AccessRequestController {
    private final AccessRequestRepository requests;
    private final AccessPolicy policy;

    public AccessRequestController(AccessRequestRepository requests, AccessPolicy policy) {
        this.requests = requests;
        this.policy = policy;
    }

    public record StatusResponse(String status) { }

    @GetMapping("/access-requests/me")
    public StatusResponse myStatus(JwtAuthenticationToken authentication) {
        if (policy.isAdmin(authentication)) {
            return new StatusResponse("APPROVED");
        }
        return requests.findByGoogleSub(authentication.getToken().getSubject())
                .map(request -> new StatusResponse(request.getStatus().name()))
                .orElseGet(() -> new StatusResponse("NOT_REQUESTED"));
    }

    @PostMapping("/access-requests")
    @Transactional
    public StatusResponse requestAccess(JwtAuthenticationToken authentication) {
        if (policy.isAdmin(authentication)) {
            return new StatusResponse("APPROVED");
        }

        Jwt jwt = authentication.getToken();
        String email = Boolean.TRUE.equals(jwt.getClaimAsBoolean("email_verified"))
                ? jwt.getClaimAsString("email") : null;

        AccessRequest request = requests.findByGoogleSub(jwt.getSubject())
                .orElseGet(() -> requests.save(new AccessRequest(jwt.getSubject(), email)));
        request.resubmit(email);
        return new StatusResponse(request.getStatus().name());
    }

    @GetMapping("/admin/access-requests")
    public List<AccessRequest> listRequests() {
        return requests.findAllByOrderByRequestedAtDesc();
    }

    @PostMapping("/admin/access-requests/{id}/approve")
    @Transactional
    public StatusResponse approve(@PathVariable Long id,
                                  JwtAuthenticationToken authentication) {
        AccessRequest request = getRequest(id);
        request.approve(authentication.getToken().getSubject());
        return new StatusResponse(request.getStatus().name());
    }

    @PostMapping("/admin/access-requests/{id}/reject")
    @Transactional
    public StatusResponse reject(@PathVariable Long id,
                                 JwtAuthenticationToken authentication) {
        AccessRequest request = getRequest(id);
        request.reject(authentication.getToken().getSubject());
        return new StatusResponse(request.getStatus().name());
    }

    private AccessRequest getRequest(Long id) {
        return requests.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Access request not found"));
    }
}
