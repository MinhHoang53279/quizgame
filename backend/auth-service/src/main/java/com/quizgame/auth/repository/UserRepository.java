package com.quizgame.auth.repository;

import com.quizgame.auth.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository interface để tương tác với collection User trong MongoDB.
 * Cung cấp các phương thức CRUD cơ bản và các phương thức truy vấn người dùng theo username, email.
 */
@Repository
public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
} 