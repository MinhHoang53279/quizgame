package com.quizgame.quiz.controller;

import com.quizgame.quiz.dto.CreateQuizRequest;
import com.quizgame.quiz.dto.StartQuizResponse;
import com.quizgame.quiz.dto.SubmitAnswerRequest;
import com.quizgame.quiz.model.Quiz;
import com.quizgame.quiz.service.QuizService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/quizzes")
public class QuizController {

    @Autowired
    private QuizService quizService;

    @PostMapping
    public ResponseEntity<StartQuizResponse> createQuiz(@RequestBody CreateQuizRequest request) {
        try {
            StartQuizResponse response = quizService.createQuiz(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null); // Cần xử lý lỗi tốt hơn
        }
    }

    @PostMapping("/submit")
    public ResponseEntity<Integer> submitAnswer(@RequestBody SubmitAnswerRequest request) {
        try {
            int currentScore = quizService.submitAnswer(request);
            return ResponseEntity.ok(currentScore);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null); // Cần xử lý lỗi tốt hơn
        }
    }

    @GetMapping("/{quizId}")
    public ResponseEntity<Quiz> getQuizById(@PathVariable String quizId) {
        return quizService.getQuizById(quizId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Quiz>> getQuizHistory(@PathVariable String userId) {
        List<Quiz> history = quizService.getQuizHistory(userId);
        return ResponseEntity.ok(history);
    }
} 