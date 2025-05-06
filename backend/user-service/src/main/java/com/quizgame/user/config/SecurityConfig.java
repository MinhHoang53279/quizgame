package com.quizgame.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

/**
 * Lớp cấu hình bảo mật cho User Service.
 * @EnableWebSecurity bật hỗ trợ bảo mật web.
 * @EnableMethodSecurity bật bảo mật ở cấp độ phương thức (ví dụ: @PreAuthorize).
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    /**
     * Định nghĩa chuỗi bộ lọc bảo mật.
     * Cấu hình CORS, CSRF, quản lý session và quy tắc ủy quyền.
     * Cho phép truy cập công khai vào actuator và API user.
     * @param http Đối tượng HttpSecurity để cấu hình.
     * @return SecurityFilterChain đã cấu hình.
     * @throws Exception Nếu có lỗi.
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(AntPathRequestMatcher.antMatcher("/actuator/**")).permitAll()
                .requestMatchers(AntPathRequestMatcher.antMatcher("/api/users/**")).permitAll()
                .anyRequest().authenticated()
            );

        return http.build();
    }

    /**
     * Tạo bean PasswordEncoder.
     * Sử dụng BCrypt để mã hóa mật khẩu (cần thiết nếu user-service tự quản lý mật khẩu).
     * @return BCryptPasswordEncoder.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Cấu hình CORS cho User Service.
     * (Lưu ý: Có thể không cần thiết nếu Gateway đã xử lý CORS).
     * Hiện tại đang cho phép mọi nguồn gốc (*), cần xem xét lại cho môi trường production.
     * @return Nguồn cấu hình CORS.
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token", "origin", "accept", "x-requested-with"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
} 