package com.divijwadhawan.golfparts;

import java.util.Map;

import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MeController {

    @GetMapping("/me")
    public Map<String, String> me(JwtAuthenticationToken authentication) {
        return Map.of("subject", authentication.getToken().getSubject());
    }
}