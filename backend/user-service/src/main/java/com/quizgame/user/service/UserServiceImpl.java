package com.quizgame.user.service;

import com.quizgame.user.model.User;
import com.quizgame.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Lớp triển khai các hoạt động nghiệp vụ cho User Service.
 * Tương tác với UserRepository để thực hiện các thao tác CRUD và cập nhật.
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Tạo người dùng mới, kiểm tra trùng lặp username/email và mã hóa mật khẩu.
     */
    @Override
    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists!");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists!");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            user.setRoles(Set.of("USER"));
        }
        return userRepository.save(user);
    }

    /**
     * Cập nhật thông tin người dùng, kiểm tra trùng lặp username/email nếu thay đổi.
     * Mật khẩu được mã hóa nếu được cung cấp.
     */
    @Override
    public Optional<User> updateUser(String id, User updatedUser) {
        return userRepository.findById(id).map(existingUser -> {
            if (updatedUser.getUsername() != null && !updatedUser.getUsername().equals(existingUser.getUsername())) {
                if (userRepository.existsByUsername(updatedUser.getUsername())) {
                    throw new RuntimeException("Username already exists!");
                }
                existingUser.setUsername(updatedUser.getUsername());
            }
            if (updatedUser.getEmail() != null && !updatedUser.getEmail().equals(existingUser.getEmail())) {
                if (userRepository.existsByEmail(updatedUser.getEmail())) {
                    throw new RuntimeException("Email already exists!");
                }
                existingUser.setEmail(updatedUser.getEmail());
            }
            if (updatedUser.getFullName() != null) {
                existingUser.setFullName(updatedUser.getFullName());
            }
            if (updatedUser.getPassword() != null && !updatedUser.getPassword().isEmpty()) {
                existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
            }
            if (updatedUser.getRoles() != null && !updatedUser.getRoles().isEmpty()) {
                existingUser.setRoles(updatedUser.getRoles());
            }
            return userRepository.save(existingUser);
        });
    }

    /**
     * Xóa người dùng theo ID.
     */
    @Override
    public void deleteUser(String id) {
        userRepository.deleteById(id);
    }

    /**
     * Lấy thông tin người dùng theo ID.
     */
    @Override
    public Optional<User> getUserById(String id) {
        return userRepository.findById(id);
    }

    /**
     * Lấy thông tin người dùng theo username.
     */
    @Override
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * Lấy danh sách tất cả người dùng.
     */
    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    /**
     * Kiểm tra username tồn tại.
     */
    @Override
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    /**
     * Kiểm tra email tồn tại.
     */
    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * Cập nhật điểm cho người dùng.
     */
    @Override
    public Optional<User> updateScore(String userId, int scoreChange) {
        return userRepository.findById(userId)
                .map(user -> {
                    user.setScore(user.getScore() + scoreChange);
                    return userRepository.save(user);
                });
    }
} 