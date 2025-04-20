package com.quizgame.auth.controller;

import com.quizgame.auth.dto.*;
import com.quizgame.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// Removed @CrossOrigin annotation as CORS is handled globally by the API Gateway
// @CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(201).body(response);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            authService.forgotPassword(request.getEmail());
            return ResponseEntity.ok().body("If your email exists in our system, a password reset link has been simulated (check backend console).");
        } catch (Exception e) {
            System.err.println("Error during forgot password: " + e.getMessage());
            return ResponseEntity.ok().body("Password reset request processed.");
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        try {
            authService.resetPassword(request.getToken(), request.getNewPassword());
            return ResponseEntity.ok().body("Password has been successfully reset.");
        } catch (RuntimeException e) {
            System.err.println("Error during reset password: " + e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
} 