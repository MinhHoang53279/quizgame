package com.quizgame.quiz.feign;

import com.quizgame.quiz.dto.ScoreUpdateRequestDTO; // Cần tạo DTO này
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

// Name phải trùng với spring.application.name của user-service
@FeignClient(name = "user-service")
public interface UserServiceClient {

    // Endpoint để cập nhật điểm
    @PutMapping("/api/users/{userId}/score")
    ResponseEntity<Void> updateUserScore(
            @PathVariable("userId") String userId,
            @RequestBody ScoreUpdateRequestDTO request);
} 