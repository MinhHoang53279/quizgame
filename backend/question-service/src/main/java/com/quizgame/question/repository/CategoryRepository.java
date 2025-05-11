package com.quizgame.question.repository;

import com.quizgame.question.model.Category;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepository extends MongoRepository<Category, String> {
    // Các phương thức tìm kiếm tùy chỉnh có thể được thêm vào đây
}
