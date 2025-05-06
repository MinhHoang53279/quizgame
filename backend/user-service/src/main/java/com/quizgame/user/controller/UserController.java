package com.quizgame.user.controller;

import com.quizgame.user.dto.CreateUserRequest;
import com.quizgame.user.dto.UpdateUserRequest;
import com.quizgame.user.dto.UserDTO;
import com.quizgame.user.model.User;
import com.quizgame.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller xử lý các yêu cầu liên quan đến quản lý người dùng (User).
 * Cung cấp các endpoint CRUD cho User và cập nhật điểm.
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Endpoint tạo người dùng mới.
     * @param request DTO chứa thông tin người dùng cần tạo.
     * @return ResponseEntity chứa UserDTO của người dùng đã tạo và mã 201 (Created).
     */
    @PostMapping
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword()); // Password will be encoded in service
        user.setFullName(request.getFullName());
        user.setRoles(request.getRoles());
        // Initial score is 0 by default in the model or set in service if needed

        User createdUser = userService.createUser(user);
        return new ResponseEntity<>(UserDTO.fromUser(createdUser), HttpStatus.CREATED);
    }

    /**
     * Endpoint cập nhật thông tin người dùng theo ID.
     * @param id ID của người dùng cần cập nhật.
     * @param request DTO chứa thông tin cập nhật.
     * @return ResponseEntity chứa UserDTO đã cập nhật hoặc 404 Not Found.
     */
    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> updateUser(@PathVariable String id, @Valid @RequestBody UpdateUserRequest request) {
        User userUpdates = new User();
        userUpdates.setUsername(request.getUsername());
        userUpdates.setEmail(request.getEmail());
        userUpdates.setPassword(request.getPassword()); // Optional password update
        userUpdates.setFullName(request.getFullName());
        userUpdates.setRoles(request.getRoles());

        return userService.updateUser(id, userUpdates)
                .map(updatedUser -> ResponseEntity.ok(UserDTO.fromUser(updatedUser)))
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Endpoint xóa người dùng theo ID.
     * @param id ID của người dùng cần xóa.
     * @return ResponseEntity 204 No Content nếu thành công hoặc 404 Not Found.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        // Check if user exists before deleting (optional, service handles not found)
        if (!userService.getUserById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Endpoint lấy thông tin người dùng theo ID.
     * @param id ID của người dùng.
     * @return ResponseEntity chứa UserDTO hoặc 404 Not Found.
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUserById(@PathVariable String id) {
        return userService.getUserById(id)
                .map(user -> ResponseEntity.ok(UserDTO.fromUser(user)))
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Endpoint lấy thông tin người dùng theo username.
     * @param username Tên đăng nhập.
     * @return ResponseEntity chứa UserDTO hoặc 404 Not Found.
     */
    @GetMapping("/username/{username}")
    public ResponseEntity<UserDTO> getUserByUsername(@PathVariable String username) {
        return userService.getUserByUsername(username)
                .map(user -> ResponseEntity.ok(UserDTO.fromUser(user)))
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Endpoint lấy danh sách tất cả người dùng.
     * @return ResponseEntity chứa danh sách UserDTO.
     */
    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        List<UserDTO> userDTOs = userService.getAllUsers().stream()
                .map(UserDTO::fromUser)
                .collect(Collectors.toList());
        return ResponseEntity.ok(userDTOs);
    }

    /**
     * Endpoint cập nhật điểm cho người dùng.
     * @param id ID của người dùng.
     * @param scoreChange Số điểm thay đổi (có thể âm hoặc dương).
     * @return ResponseEntity chứa UserDTO đã cập nhật hoặc 404 Not Found.
     */
    @PatchMapping("/{id}/score")
    public ResponseEntity<UserDTO> updateScore(@PathVariable String id, @RequestBody int scoreChange) { // Assuming simple int for change
        return userService.updateScore(id, scoreChange)
                .map(updatedUser -> ResponseEntity.ok(UserDTO.fromUser(updatedUser)))
                .orElse(ResponseEntity.notFound().build());
    }
} 