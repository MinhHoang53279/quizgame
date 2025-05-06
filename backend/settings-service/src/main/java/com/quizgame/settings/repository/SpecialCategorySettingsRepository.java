package com.quizgame.settings.repository;

import com.quizgame.settings.model.SpecialCategorySettings;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpecialCategorySettingsRepository extends MongoRepository<SpecialCategorySettings, String> {
    // Tương tự, findById("global_special_category_settings") sẽ được sử dụng
} 