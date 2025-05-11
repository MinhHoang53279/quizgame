package com.quizgame.auth.config;

import com.quizgame.auth.security.JwtAuthenticationFilter;
import com.quizgame.auth.security.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
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
// import org.springframework.web.cors.CorsConfiguration; // Tạm vô hiệu hóa
// import org.springframework.web.cors.CorsConfigurationSource; // Tạm vô hiệu hóa
// import org.springframework.web.cors.UrlBasedCorsConfigurationSource; // Tạm vô hiệu hóa

// import java.util.Arrays; // Tạm vô hiệu hóa
// import java.util.Collections; // Tạm vô hiệu hóa

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
            // .cors(cors -> cors.configurationSource(corsConfigurationSource())) // TẠM THỜI VÔ HIỆU HÓA CORS Ở AUTH-SERVICE
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // Không tạo session
            .authorizeHttpRequests(auth -> auth
                // QUAN TRỌNG: Định nghĩa quy tắc permitAll() TRƯỚC
                .requestMatchers("/api/auth/**").permitAll() // Cho phép tất cả các yêu cầu đến /api/auth/**
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll() // Cho phép tất cả các yêu cầu OPTIONS
                // Sau đó định nghĩa quy tắc cho các yêu cầu khác
                .anyRequest().permitAll() // Tạm thời cho phép tất cả các yêu cầu để kiểm tra
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

    /* // TẠM THỜI VÔ HIỆU HÓA TOÀN BỘ BEAN NÀY
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Collections.singletonList("*")); // Cho phép tất cả origins
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")); // Cho phép các phương thức HTTP
        configuration.setAllowedHeaders(Arrays.asList(
            "Authorization", "Content-Type", "Accept", 
            "X-Requested-With", "Origin", 
            "Access-Control-Request-Method", "Access-Control-Request-Headers"
        )); // Mở rộng các header được phép
        configuration.setExposedHeaders(Arrays.asList("Authorization")); // Cho phép client truy cập header Authorization
        configuration.setAllowCredentials(false); // Đặt thành false khi dùng allowedOrigins: "*"
        configuration.setMaxAge(3600L); // Thời gian cache preflight request

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration); // Áp dụng cho tất cả các đường dẫn
        return source;
    }
    */
}