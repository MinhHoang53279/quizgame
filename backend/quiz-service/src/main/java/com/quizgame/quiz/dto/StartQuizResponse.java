package com.quizgame.quiz.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StartQuizResponse {
    private String quizId;
    private List<QuizQuestionDTO> questions;
} 