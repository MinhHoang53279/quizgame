package com.quizgame.admindashboard.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin") // Base path matches the gateway route predicate
public class DashboardController {

    // Placeholder data similar to the R example
    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();

        Map<String, Integer> users = new HashMap<>();
        users.put("total", 155); // Sample data
        users.put("new_today", 7);
        summary.put("users", users);

        Map<String, Integer> quizzes = new HashMap<>();
        quizzes.put("total", 28);
        quizzes.put("active", 22);
        summary.put("quizzes", quizzes);

        List<Map<String, Object>> recentActivity = Arrays.asList(
                Map.of("user", "Charlie", "action", "updated profile", "timestamp", Instant.now().minusSeconds(1800)),
                Map.of("user", "Alice", "action", "completed quiz", "timestamp", Instant.now().minusSeconds(3600)),
                Map.of("user", "Bob", "action", "registered", "timestamp", Instant.now().minusSeconds(7200))
        );
        summary.put("recent_activity", recentActivity);

        // Add other relevant data...

        return ResponseEntity.ok(summary);
    }

    // Add other admin-related endpoints here
    // e.g., GET /users, POST /users, DELETE /quiz/{id} etc.
} 