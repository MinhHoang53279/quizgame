package com.quizgame.quiz.dto;

import lombok.Data;

@Data
public class CreateQuizRequest {
    private String userId; // ID người dùng (sau này có thể lấy từ token)
    private String category; // Optional: Lọc theo category
    private String difficulty; // Optional: Lọc theo độ khó
    private int count = 10; // Số lượng câu hỏi mong muốn, mặc định là 10
} 