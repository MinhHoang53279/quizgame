package com.quizgame.settings.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "special_category_settings") // Tên collection
public class SpecialCategorySettings {

    // Sử dụng một ID cố định
    @Id
    private String id = "global_special_category_settings";

    private Boolean specialCategoryEnabled = true; // Giá trị mặc định
    private String category1Id; // ID của Category 1 được chọn
    private String category2Id; // ID của Category 2 được chọn

     // Constructor tùy chọn nếu cần
    // public SpecialCategorySettings(Boolean specialCategoryEnabled, String category1Id, String category2Id) {
    //     this.specialCategoryEnabled = specialCategoryEnabled;
    //     this.category1Id = category1Id;
    //     this.category2Id = category2Id;
    // }
} 