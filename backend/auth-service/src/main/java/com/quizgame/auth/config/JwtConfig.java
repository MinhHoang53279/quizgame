package com.quizgame.auth.config;

import com.quizgame.auth.security.JwtUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfig {
    @Bean
    public JwtUtils jwtUtils() {
        return new JwtUtils();
    }
} 