package com.quizgame.user.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.EnableMongoAuditing;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

/**
 * Cấu hình MongoDB cho User Service.
 * @EnableMongoAuditing Bật tính năng tự động ghi nhận thông tin tạo/cập nhật (nếu cần).
 * @EnableMongoRepositories chỉ định package chứa các user repository.
 */
@Configuration
@EnableMongoAuditing
@EnableMongoRepositories(basePackages = "com.quizgame.user.repository")
public class MongoConfig {
} 