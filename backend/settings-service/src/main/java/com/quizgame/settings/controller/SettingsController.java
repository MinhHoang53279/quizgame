package com.quizgame.settings.controller;

import com.quizgame.settings.dto.PointsSettingsDTO;
import com.quizgame.settings.dto.SpecialCategorySettingsDTO;
import com.quizgame.settings.service.SettingsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
// Bỏ @RequestMapping ở đây
// @RequestMapping("/api/settings") 
@RequiredArgsConstructor
@Slf4j
public class SettingsController {

    private final SettingsService settingsService;

    // <<< THÊM ENDPOINT PING ĐƠN GIẢN >>>
    @GetMapping("/api/settings/ping") // Thêm /api/settings
    public ResponseEntity<String> ping() {
        log.info("GET /api/settings/ping called");
        return ResponseEntity.ok("pong from settings-service v2"); // Thay đổi text để nhận biết
    }

    // --- Points Settings Endpoints ---

    @GetMapping("/api/settings/points") // Thêm /api/settings
    public ResponseEntity<PointsSettingsDTO> getPointsSettings() {
        log.info("GET /api/settings/points called");
        PointsSettingsDTO settings = settingsService.getPointsSettings();
        return ResponseEntity.ok(settings);
    }

    @PutMapping("/api/settings/points") // Thêm /api/settings
    public ResponseEntity<PointsSettingsDTO> updatePointsSettings(@Valid @RequestBody PointsSettingsDTO dto) {
        log.info("PUT /api/settings/points called with data: {}", dto);
        PointsSettingsDTO updatedSettings = settingsService.updatePointsSettings(dto);
        return ResponseEntity.ok(updatedSettings);
    }

    // --- Special Category Settings Endpoints ---

    @GetMapping("/api/settings/special-categories") // Thêm /api/settings
    public ResponseEntity<SpecialCategorySettingsDTO> getSpecialCategorySettings() {
        log.info("GET /api/settings/special-categories called");
        SpecialCategorySettingsDTO settings = settingsService.getSpecialCategorySettings();
        return ResponseEntity.ok(settings);
    }

    @PutMapping("/api/settings/special-categories") // Thêm /api/settings
    public ResponseEntity<SpecialCategorySettingsDTO> updateSpecialCategorySettings(@Valid @RequestBody SpecialCategorySettingsDTO dto) {
        log.info("PUT /api/settings/special-categories called with data: {}", dto);
        // Thêm validation logic nếu cần (ví dụ: categoryId không được trùng nhau)
        SpecialCategorySettingsDTO updatedSettings = settingsService.updateSpecialCategorySettings(dto);
        return ResponseEntity.ok(updatedSettings);
    }

    // Có thể thêm endpoint để lấy danh sách categories từ QuizService/CategoryService qua FeignClient nếu cần
    // @GetMapping("/available-categories")
    // public ResponseEntity<?> getAvailableCategories() { ... }
} 