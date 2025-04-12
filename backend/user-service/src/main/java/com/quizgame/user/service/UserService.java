package com.quizgame.user.service;

import com.quizgame.user.model.User;
import java.util.List;
import java.util.Optional;

// This is the interface definition
public interface UserService {
    User createUser(User user); // Consider returning UserDTO or using a request DTO
    Optional<User> updateUser(String id, User user); // Consider using a request DTO
    void deleteUser(String id);
    Optional<User> getUserById(String id);
    Optional<User> getUserByUsername(String username);
    List<User> getAllUsers();
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    Optional<User> updateScore(String userId, int scoreChange);
} 