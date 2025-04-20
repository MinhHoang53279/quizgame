package com.quizgame.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private String id;
    private String username;
    private String email;
    private String fullName;
    private int score;
    private String role;

    public AuthResponse(String token, String id, String username, String email, String fullName, int score, String role) {
        this.token = token;
        this.type = "Bearer";
        this.id = id;
        this.username = username;
        this.email = email;
        this.fullName = fullName;
        this.score = score;
        this.role = role;
    }
} 