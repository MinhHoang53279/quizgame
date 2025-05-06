package com.quizgame.apigateway.filter;

import com.quizgame.apigateway.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import io.jsonwebtoken.Claims;

@Component
public class AuthenticationFilter extends AbstractGatewayFilterFactory<AuthenticationFilter.Config> {

    @Autowired
    private RouteValidator validator;

    @Autowired
    private JwtUtil jwtUtil;

    public AuthenticationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return ((exchange, chain) -> {
            ServerHttpRequest request = exchange.getRequest();

            // Bypass authentication for public endpoints defined in RouteValidator
            if (validator.isSecured.test(request)) {
                System.out.println("!!! DEBUG: Path needs security: " + request.getURI().getPath()); // DEBUG LOG
/*
                // --- TEMPORARY DEBUGGING: BYPASS TOKEN VALIDATION ---
                System.out.println("!!! DEBUG: Bypassing token validation for path: " + request.getURI().getPath());
                // Add a dummy role header if needed by downstream, or just proceed
                ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                            .header("X-User-Role", "DEBUG_ADMIN") // Dummy role
                            .build();
                return chain.filter(exchange.mutate().request(mutatedRequest).build());
                // --- END TEMPORARY DEBUGGING ---
*/
                // Restore original logic:
                // Check if Authorization header is present
                if (!request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
                    System.err.println("!!! Auth Filter Error: Missing Authorization header for path: " + request.getURI().getPath());
                    return onError(exchange, "Missing Authorization header", HttpStatus.UNAUTHORIZED);
                }

                String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
                String token = null;

                // Check if header is not null and starts with "Bearer " correctly
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    token = authHeader.substring(7); // Extract only the token part
                } else {
                    // Header is present but malformed or doesn't start with Bearer
                    System.err.println("!!! Auth Filter Error: Invalid Authorization header format for path: " + request.getURI().getPath() + ", Header: " + authHeader);
                    return onError(exchange, "Invalid Authorization header format", HttpStatus.UNAUTHORIZED);
                }

                try {
                    // System.out.println("Attempting to validate token: [" + token + "]"); // Log token before validation (Optional)
                    boolean isValid = jwtUtil.validateToken(token);
                    // System.out.println("Token validation result: " + isValid); // Log validation result (Optional)
                    
                    // Validate the extracted JWT token
                    if (!isValid) { // Use the validation result
                       System.err.println("!!! Auth Filter Error: Invalid or expired JWT token for path: " + request.getURI().getPath());
                       return onError(exchange, "Invalid or expired JWT token", HttpStatus.UNAUTHORIZED);
                    }

                    // Extract claims and add role header
                    Claims claims = jwtUtil.extractAllClaims(token);
                    String role = claims.get("role", String.class); // Get role from claims
                    if (role == null) {
                         System.err.println("!!! Auth Filter Error: Missing role information in token for path: " + request.getURI().getPath());
                         return onError(exchange, "Missing role information in token", HttpStatus.FORBIDDEN); 
                    }
                    
                    // Mutate the request to add the role header
                    ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                            .header("X-User-Role", role) // Add the role header
                            .build();
                    
                    // Proceed with the mutated request
                    return chain.filter(exchange.mutate().request(mutatedRequest).build());

                } catch (Exception e) {
                    System.err.println("!!! Unexpected Error in AuthenticationFilter during token processing: " + e.getMessage());
                    e.printStackTrace(); // Print stack trace for unexpected errors
                    return onError(exchange, "Unauthorized access due to filter error", HttpStatus.UNAUTHORIZED);
                }
            }
            // If the endpoint is not secured (public), proceed without modification
            // System.out.println("!!! DEBUG: Path is public: " + request.getURI().getPath()); // DEBUG LOG (can be removed)
            return chain.filter(exchange);
        });
    }

    // Helper method to return error response
    private Mono<Void> onError(ServerWebExchange exchange, String err, HttpStatus httpStatus) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(httpStatus);
        // Optionally add error details to the response body
        return response.setComplete();
    }

    // Config class (can be empty if no specific config needed per route)
    public static class Config {
        // Put configuration properties here
    }
} 