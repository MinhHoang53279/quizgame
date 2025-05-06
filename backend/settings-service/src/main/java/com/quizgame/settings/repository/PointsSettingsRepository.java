package com.quizgame.settings.repository;

import com.quizgame.settings.model.PointsSettings;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
 
@Repository
public interface PointsSettingsRepository extends MongoRepository<PointsSettings, String> {
    // MongoRepository cung cấp các phương thức CRUD cơ bản (save, findById, findAll, delete, etc.)
    // Chúng ta dùng ID cố định ("global_points_settings") nên findById là đủ
} 