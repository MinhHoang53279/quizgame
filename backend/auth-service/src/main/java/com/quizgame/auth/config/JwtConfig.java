package com.quizgame.auth.config;

import com.quizgame.auth.security.JwtUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfig {
    
    /**
     * Tạo một bean JwtUtils để sử dụng trong ứng dụng.
     * JwtUtils chịu trách nhiệm tạo và xác thực token JWT.
     * @return một thể hiện của JwtUtils.
     */
    @Bean
    public JwtUtils jwtUtils() {
        return new JwtUtils();
    }
} 