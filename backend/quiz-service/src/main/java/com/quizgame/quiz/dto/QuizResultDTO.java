package com.quizgame.quiz.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuizResultDTO {
    private String quizId;
    private String userId;
    private int score;
    private int totalQuestions;
    private boolean completed;
    private Map<String, Integer> userAnswers;
    private Map<String, Integer> correctAnswers;
    private List<QuestionResultDTO> questionResults;
} 