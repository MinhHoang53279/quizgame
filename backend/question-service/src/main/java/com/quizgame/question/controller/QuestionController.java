package com.quizgame.question.controller;

import com.quizgame.question.model.Question;
import com.quizgame.question.service.QuestionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/questions")
public class QuestionController {
    private final QuestionService questionService;

    public QuestionController(QuestionService questionService) {
        this.questionService = questionService;
    }

    @GetMapping
    public List<Question> getAllQuestions() {
        return questionService.getAllQuestions();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Question> getQuestionById(@PathVariable String id) {
        return questionService.getQuestionById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Question createQuestion(@RequestBody Question question) {
        return questionService.createQuestion(question);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Question> updateQuestion(@PathVariable String id, @RequestBody Question question) {
        return questionService.updateQuestion(id, question)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteQuestion(@PathVariable String id) {
        if (questionService.deleteQuestion(id)) {
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/category/{category}")
    public List<Question> getQuestionsByCategory(@PathVariable String category) {
        return questionService.getQuestionsByCategory(category);
    }

    @GetMapping("/difficulty/{difficulty}")
    public List<Question> getQuestionsByDifficulty(@PathVariable String difficulty) {
        return questionService.getQuestionsByDifficulty(difficulty);
    }

    @GetMapping("/category/{category}/difficulty/{difficulty}")
    public List<Question> getQuestionsByCategoryAndDifficulty(
            @PathVariable String category,
            @PathVariable String difficulty) {
        return questionService.getQuestionsByCategoryAndDifficulty(category, difficulty);
    }

    @GetMapping("/random")
    public List<Question> getRandomQuestions(@RequestParam(defaultValue = "10") int count) {
        return questionService.getRandomQuestions(count);
    }

    @GetMapping("/random/category/{category}")
    public List<Question> getRandomQuestionsByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "10") int count) {
        return questionService.getRandomQuestionsByCategory(category, count);
    }

    @GetMapping("/random/difficulty/{difficulty}")
    public List<Question> getRandomQuestionsByDifficulty(
            @PathVariable String difficulty,
            @RequestParam(defaultValue = "10") int count) {
        return questionService.getRandomQuestionsByDifficulty(difficulty, count);
    }

    @GetMapping("/random/category/{category}/difficulty/{difficulty}")
    public List<Question> getRandomQuestionsByCategoryAndDifficulty(
            @PathVariable String category,
            @PathVariable String difficulty,
            @RequestParam(defaultValue = "10") int count) {
        return questionService.getRandomQuestionsByCategoryAndDifficulty(category, difficulty, count);
    }
} 