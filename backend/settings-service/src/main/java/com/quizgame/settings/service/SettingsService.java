package com.quizgame.settings.service;

import com.quizgame.settings.dto.PointsSettingsDTO;
import com.quizgame.settings.dto.SpecialCategorySettingsDTO;
import com.quizgame.settings.model.PointsSettings;
import com.quizgame.settings.model.SpecialCategorySettings;
import com.quizgame.settings.repository.PointsSettingsRepository;
import com.quizgame.settings.repository.SpecialCategorySettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Mặc dù MongoDB ko hỗ trợ transaction truyền thống như SQL, annotation này vẫn hữu ích cho việc quản lý đơn vị công việc logic

@Service
@RequiredArgsConstructor
@Slf4j
public class SettingsService {

    private final PointsSettingsRepository pointsSettingsRepository;
    private final SpecialCategorySettingsRepository specialCategorySettingsRepository;

    private static final String GLOBAL_POINTS_ID = "global_points_settings";
    private static final String GLOBAL_SPECIAL_CATEGORY_ID = "global_special_category_settings";

    // --- Points Settings Logic ---

    public PointsSettingsDTO getPointsSettings() {
        log.debug("Fetching points settings");
        PointsSettings settings = pointsSettingsRepository.findById(GLOBAL_POINTS_ID)
                .orElseGet(() -> {
                    log.info("Points settings not found, creating default.");
                    return pointsSettingsRepository.save(new PointsSettings()); // Lưu và trả về cài đặt mặc định nếu chưa có
                });
        return convertToPointsDTO(settings);
    }

    @Transactional
    public PointsSettingsDTO updatePointsSettings(PointsSettingsDTO dto) {
        log.info("Updating points settings");
        PointsSettings settings = pointsSettingsRepository.findById(GLOBAL_POINTS_ID)
                .orElseGet(PointsSettings::new); // Lấy hoặc tạo mới nếu không có

        settings.setNewUserReward(dto.getNewUserReward());
        settings.setCorrectAnswerReward(dto.getCorrectAnswerReward());
        settings.setIncorrectAnswerPenalty(dto.getIncorrectAnswerPenalty());
        settings.setSelfChallengeModeEnabled(dto.getSelfChallengeModeEnabled());
        settings.setRequiredPointsSelfChallenge(dto.getRequiredPointsSelfChallenge());

        PointsSettings updatedSettings = pointsSettingsRepository.save(settings);
        log.info("Points settings updated successfully");
        return convertToPointsDTO(updatedSettings);
    }

    // --- Special Category Settings Logic ---

    public SpecialCategorySettingsDTO getSpecialCategorySettings() {
        log.debug("Fetching special category settings");
        SpecialCategorySettings settings = specialCategorySettingsRepository.findById(GLOBAL_SPECIAL_CATEGORY_ID)
                .orElseGet(() -> {
                     log.info("Special category settings not found, creating default.");
                     // Cần category IDs mặc định hợp lệ hoặc null
                     // Lấy từ config hoặc để null ban đầu?
                     // return specialCategorySettingsRepository.save(new SpecialCategorySettings(true, null, null)); // <-- OLD INCORRECT WAY
                     
                     // Create default using no-args constructor and setters
                     SpecialCategorySettings defaultSettings = new SpecialCategorySettings();
                     defaultSettings.setSpecialCategoryEnabled(true);
                     defaultSettings.setCategory1Id(null); // Default to null
                     defaultSettings.setCategory2Id(null); // Default to null
                     // The ID is already set by default in the model
                     return specialCategorySettingsRepository.save(defaultSettings);
                });
        return convertToSpecialCategoryDTO(settings);
    }

    @Transactional
    public SpecialCategorySettingsDTO updateSpecialCategorySettings(SpecialCategorySettingsDTO dto) {
        log.info("Updating special category settings");
         // Validate category IDs if necessary (e.g., check if they exist via Feign client?)
         // For now, we just save what the admin provides.
        SpecialCategorySettings settings = specialCategorySettingsRepository.findById(GLOBAL_SPECIAL_CATEGORY_ID)
                .orElseGet(SpecialCategorySettings::new);

        settings.setSpecialCategoryEnabled(dto.getSpecialCategoryEnabled());
        // Chỉ cập nhật IDs nếu chế độ được bật?
        if (Boolean.TRUE.equals(dto.getSpecialCategoryEnabled())) {
            settings.setCategory1Id(dto.getCategory1Id());
            settings.setCategory2Id(dto.getCategory2Id());
        } else {
             // Set IDs to null if disabled?
             settings.setCategory1Id(null);
             settings.setCategory2Id(null);
        }

        SpecialCategorySettings updatedSettings = specialCategorySettingsRepository.save(settings);
        log.info("Special category settings updated successfully");
        return convertToSpecialCategoryDTO(updatedSettings);
    }

    // --- Helper Conversion Methods ---

    private PointsSettingsDTO convertToPointsDTO(PointsSettings entity) {
        return new PointsSettingsDTO(
                entity.getNewUserReward(),
                entity.getCorrectAnswerReward(),
                entity.getIncorrectAnswerPenalty(),
                entity.getSelfChallengeModeEnabled(),
                entity.getRequiredPointsSelfChallenge()
        );
    }

    private SpecialCategorySettingsDTO convertToSpecialCategoryDTO(SpecialCategorySettings entity) {
        return new SpecialCategorySettingsDTO(
                entity.getSpecialCategoryEnabled(),
                entity.getCategory1Id(),
                entity.getCategory2Id()
        );
    }
} 