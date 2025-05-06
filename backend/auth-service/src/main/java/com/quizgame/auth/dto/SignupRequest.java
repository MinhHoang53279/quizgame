package com.quizgame.auth.dto;

import lombok.Data;
import java.util.List;
import java.util.Set;

/**
 * DTO chứa thông tin đăng ký.
 * (Lưu ý: Lớp RegisterRequest có vẻ đang được sử dụng thay thế lớp này).
 */
@Data
public class SignupRequest {
    private String username;
    private String email;
    private String password;
    private String fullName;
    private List<String> roles;
} 