package com.quizgame.settings.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PointsSettingsDTO {

    @NotNull(message = "New user reward cannot be null")
    @Min(value = 0, message = "Reward must be non-negative")
    private Integer newUserReward;

    @NotNull(message = "Correct answer reward cannot be null")
    @Min(value = 0, message = "Reward must be non-negative")
    private Integer correctAnswerReward;

    @NotNull(message = "Incorrect answer penalty cannot be null")
    @Min(value = 0, message = "Penalty must be non-negative")
    private Integer incorrectAnswerPenalty;

    @NotNull(message = "Self challenge mode setting cannot be null")
    private Boolean selfChallengeModeEnabled;

    // Chỉ validate nếu selfChallengeModeEnabled là true?
    // Hoặc để validation ở service layer
    @NotNull(message = "Required points for self challenge cannot be null")
    @Min(value = 0, message = "Points must be non-negative")
    private Integer requiredPointsSelfChallenge;
} 