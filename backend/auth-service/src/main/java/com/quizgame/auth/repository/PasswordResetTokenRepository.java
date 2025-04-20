package com.quizgame.auth.repository;

import com.quizgame.auth.model.PasswordResetToken;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.Optional;

public interface PasswordResetTokenRepository extends MongoRepository<PasswordResetToken, String> {

    Optional<PasswordResetToken> findByToken(String token);

    void deleteByUserId(String userId);

    void deleteByExpiryDateBefore(java.time.Instant now);
} 