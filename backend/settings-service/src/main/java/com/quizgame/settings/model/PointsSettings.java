package com.quizgame.settings.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "points_settings") // Tên collection trong MongoDB
public class PointsSettings {

    // Sử dụng một ID cố định để đảm bảo chỉ có một document cài đặt điểm
    @Id
    private String id = "global_points_settings";

    private Integer newUserReward = 50; // Giá trị mặc định
    private Integer correctAnswerReward = 2;
    private Integer incorrectAnswerPenalty = 1;
    private Boolean selfChallengeModeEnabled = true;
    private Integer requiredPointsSelfChallenge = 2;

    // Constructor tùy chọn nếu cần
    // public PointsSettings(Integer newUserReward, Integer correctAnswerReward, Integer incorrectAnswerPenalty, Boolean selfChallengeModeEnabled, Integer requiredPointsSelfChallenge) {
    //     this.newUserReward = newUserReward;
    //     this.correctAnswerReward = correctAnswerReward;
    //     this.incorrectAnswerPenalty = incorrectAnswerPenalty;
    //     this.selfChallengeModeEnabled = selfChallengeModeEnabled;
    //     this.requiredPointsSelfChallenge = requiredPointsSelfChallenge;
    // }
} 