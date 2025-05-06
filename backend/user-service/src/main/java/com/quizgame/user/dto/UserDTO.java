package com.quizgame.user.dto;

import com.quizgame.user.model.User;
import lombok.Data;
import java.util.Set;

/**
 * DTO đại diện cho thông tin người dùng sẽ được trả về cho client.
 * Không chứa mật khẩu.
 */
@Data
public class UserDTO {
    private String id;
    private String username;
    private String email;
    private String fullName;
    private int score;
    private Set<String> roles;

    /**
     * Phương thức factory để chuyển đổi từ đối tượng User model sang UserDTO.
     * @param user Đối tượng User model.
     * @return Đối tượng UserDTO tương ứng.
     */
    public static UserDTO fromUser(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setScore(user.getScore());
        dto.setRoles(user.getRoles());
        return dto;
    }
}
 