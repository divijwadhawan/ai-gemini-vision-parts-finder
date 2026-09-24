package com.example.workout_api;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http, AccessPolicy policy)
            throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.GET, "/me", "/access-requests/me")
                            .authenticated()
                        .requestMatchers(HttpMethod.POST, "/access-requests")
                            .authenticated()
                        .requestMatchers("/admin/access-requests", "/admin/access-requests/**")
                            .access((authentication, context) ->
                                new AuthorizationDecision(policy.isAdmin(authentication.get())))
                        .requestMatchers(HttpMethod.GET, "/vehicles/**")
                            .access((authentication, context) ->
                                new AuthorizationDecision(policy.canReadParts(authentication.get())))
                        .requestMatchers(HttpMethod.POST, "/parts")
                            .access((authentication, context) ->
                                new AuthorizationDecision(policy.isAdmin(authentication.get())))
                        .anyRequest().denyAll())
                .oauth2ResourceServer(oauth -> oauth.jwt(Customizer.withDefaults()))
                .build();
    }
}
