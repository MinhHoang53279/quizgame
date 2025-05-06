package com.quizgame.eureka;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * Lớp chính khởi chạy ứng dụng Eureka Server.
 * Annotation @EnableEurekaServer kích hoạt chức năng của một Eureka Server.
 * Annotation @SpringBootApplication bao gồm @Configuration, @EnableAutoConfiguration, @ComponentScan.
 */
@SpringBootApplication
@EnableEurekaServer
public class EurekaServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServiceApplication.class, args);
    }
} 