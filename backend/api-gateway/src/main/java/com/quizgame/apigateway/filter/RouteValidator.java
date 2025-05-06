package com.quizgame.apigateway.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Predicate;

/**
 * Component giúp xác định xem một request có cần xác thực hay không.
 * Dựa trên việc kiểm tra URI của request có nằm trong danh sách các endpoint công khai không.
 */
@Component
public class RouteValidator {

    // Danh sách các endpoint công khai (không yêu cầu xác thực JWT)
    public static final List<String> openApiEndpoints = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/api/auth/forgot-password", // Thêm forgot-password
            "/api/auth/reset-password", // Thêm reset-password
            "/eureka" // Cho phép truy cập nội bộ của Eureka
            // Add other public endpoints like swagger if needed
    );

    // Predicate để kiểm tra: trả về true nếu request cần được bảo mật (secured),
    // tức là URI không khớp với bất kỳ endpoint công khai nào.
    public Predicate<ServerHttpRequest> isSecured =
            request -> openApiEndpoints
                    .stream()
                    .noneMatch(uri -> request.getURI().getPath().contains(uri));

} 