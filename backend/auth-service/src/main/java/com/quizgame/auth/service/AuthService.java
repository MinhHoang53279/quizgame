package com.quizgame.auth.service;

import com.quizgame.auth.dto.AuthResponse;
import com.quizgame.auth.dto.LoginRequest;
import com.quizgame.auth.dto.RegisterRequest;
import com.quizgame.auth.model.User;
import com.quizgame.auth.model.PasswordResetToken;
import com.quizgame.auth.repository.UserRepository;
import com.quizgame.auth.repository.PasswordResetTokenRepository;
import com.quizgame.auth.security.JwtUtils;
import com.quizgame.auth.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final PasswordResetTokenRepository passwordResetTokenRepository;

    @Value("${password.reset.token.expiration}")
    private Long passwordResetTokenExpirationMs;

    @Value("${frontend.base.url:http://localhost:59242}")
    private String frontendBaseUrl;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Attempting to register user: {}", request.getUsername());
        
        if (userRepository.existsByUsername(request.getUsername())) {
            log.warn("Username is already taken: {}", request.getUsername());
            throw new RuntimeException("Username is already taken!");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            log.warn("Email is already in use: {}", request.getEmail());
            throw new RuntimeException("Email is already in use!");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setRole("USER");

        try {
            user = userRepository.save(user);
            log.info("Successfully registered user: {}", user.getUsername());
        } catch (Exception e) {
            log.error("Error saving user to database", e);
            throw new RuntimeException("Error registering user", e);
        }

        String jwt = jwtUtils.generateToken(UserDetailsImpl.build(user));
        return new AuthResponse(jwt, user.getId(), user.getUsername(), user.getEmail(), user.getFullName(), user.getScore(), user.getRole());
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        log.info("Attempting to login user: {}", request.getUsername());
        
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            String jwt = jwtUtils.generateToken(userDetails);

            log.info("Successfully logged in user: {}", userDetails.getUsername());
            
            User loggedInUser = userRepository.findByUsername(userDetails.getUsername())
                                             .orElseThrow(() -> new RuntimeException("User vanished after authentication!")); // Should not happen

            return new AuthResponse(
                jwt,
                loggedInUser.getId(),
                loggedInUser.getUsername(),
                loggedInUser.getEmail(),
                loggedInUser.getFullName(),
                loggedInUser.getScore(),
                loggedInUser.getAuthorities().iterator().next().getAuthority() // Assuming single role
            );
        } catch (Exception e) {
            log.error("Error during login for user: {}", request.getUsername(), e);
            throw new RuntimeException("Invalid username or password.");
        }
    }

    @Transactional
    public void forgotPassword(String email) {
        log.info("Forgot password request received for email: {}", email);
        Optional<User> userOptional = userRepository.findByEmail(email);

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            String token = UUID.randomUUID().toString();
            Instant expiryDate = Instant.now().plusMillis(passwordResetTokenExpirationMs);

            passwordResetTokenRepository.deleteByUserId(user.getId());

            PasswordResetToken resetToken = new PasswordResetToken(token, user.getId(), expiryDate);
            passwordResetTokenRepository.save(resetToken);

            String resetUrl = frontendBaseUrl + "/reset-password?token=" + token;
            log.info("Password reset requested for user: {}. Reset Token: {}", user.getUsername(), token);
            log.info("SIMULATED EMAIL: To reset your password, click here: {}", resetUrl);

        } else {
            log.warn("Forgot password request for non-existent email: {}", email);
        }
    }

    @Transactional
    public void resetPassword(String token, String newPassword) {
        log.info("Reset password attempt with token: {}", token);
        Optional<PasswordResetToken> tokenOptional = passwordResetTokenRepository.findByToken(token);

        if (tokenOptional.isEmpty()) {
            log.error("Invalid password reset token provided: {}", token);
            throw new RuntimeException("Invalid or expired password reset token.");
        }

        PasswordResetToken resetToken = tokenOptional.get();

        if (resetToken.isExpired()) {
            log.error("Expired password reset token used: {}", token);
            passwordResetTokenRepository.delete(resetToken);
            throw new RuntimeException("Invalid or expired password reset token.");
        }

        User user = userRepository.findById(resetToken.getUserId())
                .orElseThrow(() -> {
                    log.error("User not found for valid reset token: {}", token);
                    passwordResetTokenRepository.delete(resetToken);
                    return new RuntimeException("User associated with token not found.");
                });

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        log.info("Password successfully reset for user: {}", user.getUsername());

        passwordResetTokenRepository.delete(resetToken);
        log.info("Password reset token deleted: {}", token);
    }
} 