package com.quizgame.quiz.dto;

import lombok.Data;

@Data
public class SubmitAnswerRequest {
    private String quizId;
    private String questionId;
    private int answerIndex; // Index câu trả lời của người dùng
} 