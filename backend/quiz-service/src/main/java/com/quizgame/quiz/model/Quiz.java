package com.quizgame.quiz.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;
import java.util.Map;

@Data
@Document(collection = "quizzes")
public class Quiz {
    @Id
    private String id;

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotNull(message = "Question IDs are required")
    @Size(min = 1, message = "At least one question is required")
    private List<String> questionIds;

    @NotNull(message = "Answers map is required")
    private Map<String, Integer> answers;

    private int score;
    private boolean completed;
} 