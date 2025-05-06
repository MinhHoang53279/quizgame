package com.quizgame.user.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

/**
 * Bộ xử lý ngoại lệ (Exception Handler) toàn cục cho ứng dụng.
 * Bắt các exception xảy ra trong controller và trả về phản hồi lỗi chuẩn hóa.
 * @ControllerAdvice cho phép áp dụng handler này cho tất cả các controller.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Xử lý các RuntimeException (thường là lỗi nghiệp vụ dự kiến).
     * @param ex Ngoại lệ RuntimeException.
     * @return ResponseEntity với mã lỗi 400 (Bad Request) và thông báo lỗi.
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<String> handleRuntimeException(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.getMessage());
    }

    /**
     * Xử lý các Exception chung (lỗi không mong đợi).
     * @param ex Ngoại lệ Exception.
     * @return ResponseEntity với mã lỗi 500 (Internal Server Error) và thông báo lỗi.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Đã xảy ra lỗi không xác định: " + ex.getMessage());
    }
} 