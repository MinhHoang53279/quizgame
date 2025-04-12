package com.quizgame.quiz.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuestionResultDTO {
    private String questionId;
    private String questionText;
    private List<String> options;
    private int userAnswerIndex;
    private int correctAnswerIndex;
    private boolean isCorrect;
} 