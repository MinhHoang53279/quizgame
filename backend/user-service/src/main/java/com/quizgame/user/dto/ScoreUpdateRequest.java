package com.quizgame.user.dto;

import lombok.Data;

@Data
public class ScoreUpdateRequest {
    private int scoreChange; // Số điểm cần cộng (dương) hoặc trừ (âm)
} 