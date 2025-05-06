package com.quizgame.user.model;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.HashSet;
import java.util.Set;

/**
 * Model đại diện cho người dùng trong User Service.
 * Chứa thông tin hồ sơ người dùng như username, email, tên đầy đủ, điểm, vai trò.
 * @Document chỉ định collection trong MongoDB.
 */
@Data
@Document(collection = "users")
public class User {
    @Id
    private String id;

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 20, message = "Username must be between 3 and 20 characters")
    private String username;

    // Password field - No validation needed here as it's handled in DTO and encoded in service
    private String password;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    private String fullName;
    private int score;
    private Set<String> roles = new HashSet<>();
} 