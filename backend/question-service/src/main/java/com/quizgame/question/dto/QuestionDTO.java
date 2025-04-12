package com.quizgame.question.dto;

import lombok.Data;
import java.util.List;

@Data
public class QuestionDTO {
    private String id;
    private String questionText;
    private List<String> options;
    private int correctAnswerIndex;
    private String category;
    private String difficulty;
} 