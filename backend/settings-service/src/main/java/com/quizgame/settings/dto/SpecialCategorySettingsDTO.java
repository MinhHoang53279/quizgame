package com.quizgame.settings.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SpecialCategorySettingsDTO {

    @NotNull(message = "Special category enabled setting cannot be null")
    private Boolean specialCategoryEnabled;

    // Cho phép null nếu specialCategoryEnabled là false?
    // Có thể cần validation tùy chỉnh trong service
    private String category1Id; 
    private String category2Id;
} 