package com.quizgame.quiz.feign;

import com.quizgame.quiz.dto.QuestionDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

// Name phải trùng với spring.application.name của question-service
// Thêm path để không cần lặp lại trong mỗi @GetMapping
@FeignClient(name = "question-service", path = "/api/questions")
public interface QuestionServiceClient {

    // Đường dẫn không cần chứa /api/questions/ nữa
    @GetMapping("/random") 
    List<QuestionDTO> getRandomQuestions(@RequestParam("count") int count);

    @GetMapping("/random/category/{category}")
    List<QuestionDTO> getRandomQuestionsByCategory(
            @PathVariable("category") String category,
            @RequestParam("count") int count);

    @GetMapping("/random/difficulty/{difficulty}")
    List<QuestionDTO> getRandomQuestionsByDifficulty(
            @PathVariable("difficulty") String difficulty,
            @RequestParam("count") int count);

    @GetMapping("/random/category/{category}/difficulty/{difficulty}")
    List<QuestionDTO> getRandomQuestionsByCategoryAndDifficulty(
            @PathVariable("category") String category,
            @PathVariable("difficulty") String difficulty,
            @RequestParam("count") int count);
    
    // Thêm phương thức lấy thông tin chi tiết của một câu hỏi theo ID
    @GetMapping("/{id}")
    QuestionDTO getQuestionById(@PathVariable("id") String id);
} 