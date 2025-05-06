package com.quizgame.auth.config;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.AbstractMongoClientConfiguration;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

/**
 * Cấu hình kết nối và tương tác với MongoDB.
 * @EnableMongoRepositories chỉ định package chứa các repository interface.
 */
@Configuration
@EnableMongoRepositories(basePackages = "com.quizgame.auth.repository")
public class MongoConfig extends AbstractMongoClientConfiguration {

    @Value("${spring.data.mongodb.uri}")
    private String mongoUri;

    /**
     * Trả về tên của cơ sở dữ liệu MongoDB sẽ sử dụng.
     * @return Tên cơ sở dữ liệu (vd: "quizgame").
     */
    @Override
    protected String getDatabaseName() {
        return "quizgame";
    }

    /**
     * Tạo và cấu hình MongoClient để kết nối đến MongoDB.
     * Sử dụng chuỗi kết nối (URI) từ tệp cấu hình.
     * @return Một thể hiện của MongoClient đã được cấu hình.
     */
    @Override
    public MongoClient mongoClient() {
        ConnectionString connectionString = new ConnectionString(mongoUri);
        MongoClientSettings mongoClientSettings = MongoClientSettings.builder()
            .applyConnectionString(connectionString)
            .build();
        return MongoClients.create(mongoClientSettings);
    }
} 