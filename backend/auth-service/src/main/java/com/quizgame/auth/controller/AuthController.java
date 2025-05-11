package com.quizgame.auth.controller;

import com.quizgame.auth.dto.*;
import com.quizgame.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller xử lý các yêu cầu liên quan đến xác thực như đăng nhập, đăng ký,
 * quên mật khẩu và đặt lại mật khẩu.
 */
// CORS is now enabled at global level in SecurityConfig.java
// @CrossOrigin(origins = "*", maxAge = 3600, allowedHeaders = {"Content-Type", "Authorization"}) // Vô hiệu hóa để tránh xung đột
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Endpoint xử lý yêu cầu đăng nhập của người dùng.
     * @param request Chứa username và password.
     * @return ResponseEntity chứa AuthResponse (token và thông tin người dùng) nếu thành công.
     */
    /**
     * Endpoint xử lý OPTIONS request cho CORS preflight.
     * Vô hiệu hóa vì đã có cấu hình CORS toàn cục trong SecurityConfig.java
     * @return ResponseEntity với các header CORS.
     */
    // @RequestMapping(value = "/login", method = RequestMethod.OPTIONS)
    // public ResponseEntity<?> handleOptionsRequest() {
    //     System.out.println("OPTIONS request received for /login endpoint");
    //     return ResponseEntity.ok().build();
    // }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        System.out.println("Login request received for username: " + request.getUsername());
        try {
            AuthResponse response = authService.login(request);
            System.out.println("Login successful for user: " + request.getUsername());
            return ResponseEntity.ok(response); // Không thêm header CORS vì đã được xử lý bởi cấu hình CORS toàn cục
        } catch (Exception e) {
            System.err.println("Login failed for user: " + request.getUsername() + ", error: " + e.getMessage());
            throw e; // Re-throw to let global exception handler handle it
        }
    }

    /**
     * Endpoint xử lý yêu cầu đăng ký tài khoản mới.
     * @param request Chứa thông tin đăng ký (username, email, password, fullName).
     * @return ResponseEntity chứa AuthResponse (token và thông tin người dùng) với mã 201 (Created) nếu thành công.
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Endpoint xử lý yêu cầu quên mật khẩu.
     * Nhận email và yêu cầu AuthService tạo token đặt lại (nếu email tồn tại).
     * Luôn trả về 200 OK để tránh tấn công liệt kê email.
     * @param request Chứa địa chỉ email.
     * @return ResponseEntity với thông báo xử lý.
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            authService.forgotPassword(request.getEmail());
            // Luôn trả về OK để ngăn chặn việc đoán email
            return ResponseEntity.ok().body("If your email exists in our system, a password reset link has been simulated (check backend console).");
        } catch (Exception e) {
            // Ghi lại lỗi nhưng vẫn trả về OK cho client
             System.err.println("Error during forgot password: " + e.getMessage());
             return ResponseEntity.ok().body("Password reset request processed."); // Thông báo chung
        }
    }

    /**
     * Endpoint xử lý yêu cầu đặt lại mật khẩu bằng token.
     * @param request Chứa token và mật khẩu mới.
     * @return ResponseEntity với thông báo thành công hoặc lỗi (ví dụ: token không hợp lệ/hết hạn).
     */
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            authService.resetPassword(request.getToken(), request.getNewPassword());
            return ResponseEntity.ok().body("Password has been successfully reset.");
        } catch (RuntimeException e) {
             System.err.println("Error during reset password: " + e.getMessage());
             // Trả về lỗi cụ thể từ service
             return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}