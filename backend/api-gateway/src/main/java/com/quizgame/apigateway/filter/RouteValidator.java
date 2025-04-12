package com.quizgame.apigateway.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Predicate;

@Component
public class RouteValidator {

    // List of public endpoints (no auth required)
    public static final List<String> openApiEndpoints = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/eureka" // Allow eureka internal traffic
            // Add other public endpoints like swagger if needed
    );

    // Predicate to check if the request URI matches any public endpoint
    public Predicate<ServerHttpRequest> isSecured = 
            request -> openApiEndpoints
                    .stream()
                    .noneMatch(uri -> request.getURI().getPath().contains(uri));

} 