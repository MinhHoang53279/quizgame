package com.quizgame.apigateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;

@Configuration
public class CorsConfig {

    @Bean
    public CorsWebFilter corsWebFilter() {

        CorsConfiguration corsConfig = new CorsConfiguration();
        // Allow requests from any localhost origin for Flutter web dev server
        // corsConfig.setAllowedOrigins(Collections.singletonList("http://localhost:51975")); // Previous specific origin
        corsConfig.setAllowedOriginPatterns(Collections.singletonList("http://localhost:*")); // Allow any port on localhost
        corsConfig.setMaxAge(3600L);
        corsConfig.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        corsConfig.setAllowedHeaders(Arrays.asList(
                "Authorization", 
                "Content-Type", 
                "Accept", 
                "X-Requested-With", 
                "Origin", 
                "Access-Control-Request-Method", 
                "Access-Control-Request-Headers"
        ));
        corsConfig.setAllowCredentials(true); // Explicitly allow credentials

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig); // Apply CORS to all paths

        return new CorsWebFilter(source);
    }
} 