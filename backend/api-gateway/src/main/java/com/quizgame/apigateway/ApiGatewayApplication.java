package com.quizgame.apigateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Lớp chính khởi chạy ứng dụng API Gateway.
 * @EnableDiscoveryClient cho phép gateway tìm và tương tác với các dịch vụ khác thông qua Eureka.
 */
@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiGatewayApplication.class, args);
	}

} 