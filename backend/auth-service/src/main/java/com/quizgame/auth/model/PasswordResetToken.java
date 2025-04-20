package com.quizgame.auth.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.time.Instant;

@Document(collection = "passwordResetTokens")
@Data
@NoArgsConstructor
public class PasswordResetToken {

    @Id
    private String id;

    @Indexed(unique = true)
    private String token;

    private String userId;

    private Instant expiryDate;

    public PasswordResetToken(String token, String userId, Instant expiryDate) {
        this.token = token;
        this.userId = userId;
        this.expiryDate = expiryDate;
    }

    public boolean isExpired() {
        return Instant.now().isAfter(expiryDate);
    }
} 