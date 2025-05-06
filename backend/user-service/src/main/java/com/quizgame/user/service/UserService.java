package com.quizgame.user.service;

import com.quizgame.user.model.User;
import java.util.List;
import java.util.Optional;

/**
 * Interface định nghĩa các hoạt động nghiệp vụ cho User Service.
 */
public interface UserService {
    /**
     * Tạo người dùng mới.
     * @param user Đối tượng User chứa thông tin ban đầu.
     * @return Đối tượng User đã được tạo và lưu.
     */
    User createUser(User user); // Consider returning UserDTO or using a request DTO

    /**
     * Cập nhật thông tin người dùng.
     * @param id ID của người dùng cần cập nhật.
     * @param user Đối tượng User chứa thông tin cập nhật.
     * @return Optional chứa User đã cập nhật nếu thành công.
     */
    Optional<User> updateUser(String id, User user); // Consider using a request DTO

    /**
     * Xóa người dùng theo ID.
     * @param id ID của người dùng cần xóa.
     */
    void deleteUser(String id);

    /**
     * Lấy thông tin người dùng theo ID.
     * @param id ID người dùng.
     * @return Optional chứa User nếu tìm thấy.
     */
    Optional<User> getUserById(String id);

    /**
     * Lấy thông tin người dùng theo username.
     * @param username Tên đăng nhập.
     * @return Optional chứa User nếu tìm thấy.
     */
    Optional<User> getUserByUsername(String username);

    /**
     * Lấy danh sách tất cả người dùng.
     * @return List các đối tượng User.
     */
    List<User> getAllUsers();

    /**
     * Kiểm tra xem username đã tồn tại chưa.
     * @param username Tên đăng nhập cần kiểm tra.
     * @return true nếu tồn tại, false nếu không.
     */
    boolean existsByUsername(String username);

    /**
     * Kiểm tra xem email đã tồn tại chưa.
     * @param email Email cần kiểm tra.
     * @return true nếu tồn tại, false nếu không.
     */
    boolean existsByEmail(String email);

    /**
     * Cập nhật điểm cho người dùng.
     * @param userId ID của người dùng.
     * @param scoreChange Lượng điểm thay đổi.
     * @return Optional chứa User đã cập nhật điểm nếu thành công.
     */
    Optional<User> updateScore(String userId, int scoreChange);
} 