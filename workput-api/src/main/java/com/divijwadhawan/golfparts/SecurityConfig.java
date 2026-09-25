package com.divijwadhawan.golfparts;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

import com.divijwadhawan.golfparts.auth.AccessPolicy;

@Configuration
public class SecurityConfig {

    private final AccessPolicy accessPolicy;

    public SecurityConfig(AccessPolicy accessPolicy) {
        this.accessPolicy = accessPolicy;
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        return http
                .csrf(csrf -> csrf.disable())

                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(auth -> auth

                        // Logged-in users can check their access status
                        .requestMatchers(HttpMethod.GET, "/access-requests/me")
                        .authenticated()

                        // Logged-in users can request access
                        .requestMatchers(HttpMethod.POST, "/access-requests")
                        .authenticated()

                        // Only the admin can view/approve/reject requests
                        .requestMatchers("/admin/**")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.isAdmin(authentication.get())
                                ))

                        // Parts can only be read by approved users
                        .requestMatchers(HttpMethod.GET, "/vehicles/**")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.canReadParts(authentication.get())
                                ))
                        
                        .requestMatchers(HttpMethod.GET, "/assemblies/**")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.canReadParts(authentication.get())
                                ))
                        
                        .requestMatchers(HttpMethod.POST, "/parts")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.isAdmin(authentication.get())
                                ))        
                        
                        .requestMatchers(HttpMethod.POST, "/scan")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.canReadParts(authentication.get())
                                ))
                        .requestMatchers(HttpMethod.GET, "/scans/me")
                        .access((authentication, context) ->
                                new AuthorizationDecision(
                                        accessPolicy.canReadParts(authentication.get())
                                ))                

                        // Existing /me endpoint
                        .requestMatchers(HttpMethod.GET, "/me")
                        .authenticated()

                       // Allow Spring to return application errors
                        .requestMatchers("/error")
                        .permitAll()

                        // Everything else is blocked
                        .anyRequest()   
                        .denyAll()
                )

                .oauth2ResourceServer(oauth ->
                        oauth.jwt(Customizer.withDefaults())
                )

                .build();
    }
}