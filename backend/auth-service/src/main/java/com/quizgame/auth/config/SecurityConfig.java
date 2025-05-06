package com.quizgame.auth.config;

import com.quizgame.auth.security.JwtAuthenticationFilter;
import com.quizgame.auth.security.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Lớp cấu hình chính cho Spring Security.
 * @EnableWebSecurity bật hỗ trợ bảo mật web của Spring Security.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsServiceImpl userDetailsService;
    private final JwtAuthenticationFilter jwtAuthFilter;

    /**
     * Định nghĩa chuỗi bộ lọc bảo mật chính.
     * Cấu hình CORS, CSRF, quản lý session, quy tắc ủy quyền và thêm bộ lọc JWT.
     * @param http Đối tượng HttpSecurity để cấu hình bảo mật.
     * @return SecurityFilterChain đã được cấu hình.
     * @throws Exception Nếu có lỗi xảy ra trong quá trình cấu hình.
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Vô hiệu hóa CSRF vì sử dụng API stateless
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // Không tạo session
            .authorizeHttpRequests(auth -> auth
                // QUAN TRỌNG: Định nghĩa quy tắc permitAll() TRƯỚC
                .requestMatchers("/api/auth/**").permitAll() // Cho phép tất cả các yêu cầu đến /api/auth/**
                // Sau đó định nghĩa quy tắc cho các yêu cầu khác
                .anyRequest().authenticated() // Mọi yêu cầu khác cần được xác thực
            )
            .authenticationProvider(authenticationProvider()) // Cung cấp authentication provider
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class); // Thêm bộ lọc JWT

        return http.build();
    }

    /**
     * Tạo bean DaoAuthenticationProvider.
     * Provider này sử dụng UserDetailsService để lấy thông tin người dùng
     * và PasswordEncoder để kiểm tra mật khẩu.
     * @return DaoAuthenticationProvider đã được cấu hình.
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService); // Dịch vụ tải chi tiết người dùng
        authProvider.setPasswordEncoder(passwordEncoder()); // Bộ mã hóa mật khẩu
        return authProvider;
    }

    /**
     * Tạo bean AuthenticationManager.
     * Đây là thành phần cốt lõi của Spring Security để xử lý xác thực.
     * @param authConfig Cấu hình xác thực.
     * @return AuthenticationManager.
     * @throws Exception Nếu có lỗi xảy ra.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    /**
     * Tạo bean PasswordEncoder.
     * Sử dụng BCrypt để mã hóa mật khẩu một cách an toàn.
     * @return Một thể hiện của BCryptPasswordEncoder.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
} 