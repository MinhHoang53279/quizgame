package com.quizgame.auth.dto;

import lombok.Data;
import java.util.List;

@Data
public class SignupRequest {
    private String username;
    private String email;
    private String password;
    private String fullName;
    private List<String> roles;
} 