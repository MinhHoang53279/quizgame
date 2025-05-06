package com.quizgame.apigateway.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.security.Key;
import java.util.Date;
import java.util.function.Function;
import java.nio.charset.StandardCharsets;
import javax.crypto.spec.SecretKeySpec;

/**
 * Lớp tiện ích xử lý JWT trong API Gateway.
 * Chủ yếu dùng để xác thực token và trích xuất thông tin (claims).
 * Sử dụng cùng secret key với auth-service.
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}") // Same secret as auth-service
    private String secret;

    private Key key;

    @PostConstruct
    public void init() {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * Trích xuất tất cả các claims từ một JWT token.
     * @param token Chuỗi JWT.
     * @return Claims object chứa tất cả thông tin trong payload.
     */
    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
    }

    /**
     * Trích xuất một claim cụ thể từ token bằng claimsResolver.
     * @param token Chuỗi JWT.
     * @param claimsResolver Hàm để lấy claim mong muốn.
     * @return Giá trị của claim.
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Trích xuất username (subject) từ token.
     * @param token Chuỗi JWT.
     * @return Username.
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Trích xuất thời gian hết hạn từ token.
     * @param token Chuỗi JWT.
     * @return Thời gian hết hạn.
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // Kiểm tra token đã hết hạn chưa.
    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Xác thực tính hợp lệ của một JWT token.
     * Kiểm tra chữ ký và thời gian hết hạn.
     * @param token Chuỗi JWT cần xác thực.
     * @return true nếu token hợp lệ, false nếu ngược lại.
     */
    public Boolean validateToken(String token) {
        System.out.println("JwtUtil: Validating token: [" + token + "]");
        try {
            System.out.println("JwtUtil: Attempting to extract claims...");
            extractAllClaims(token);
            System.out.println("JwtUtil: Claims extracted successfully.");

            System.out.println("JwtUtil: Checking expiration...");
            boolean expired = isTokenExpired(token);
            System.out.println("JwtUtil: Is token expired? " + expired);
            
            boolean result = !expired;
            System.out.println("JwtUtil: Final validation result: " + result);
            return result;
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            System.err.println("!!! JwtUtil Error: JWT token is expired: " + e.getMessage());
            return false;
        } catch (io.jsonwebtoken.UnsupportedJwtException e) {
            System.err.println("!!! JwtUtil Error: JWT token is unsupported: " + e.getMessage());
            return false;
        } catch (io.jsonwebtoken.MalformedJwtException e) {
            System.err.println("!!! JwtUtil Error: Invalid JWT token format: " + e.getMessage());
            return false;
        } catch (io.jsonwebtoken.security.SignatureException e) {
            System.err.println("!!! JwtUtil Error: Invalid JWT signature: " + e.getMessage());
            return false;
        } catch (IllegalArgumentException e) {
            System.err.println("!!! JwtUtil Error: JWT claims string is empty or invalid: " + e.getMessage());
            return false;
        } catch (Exception e) {
            // Catch any other unexpected exceptions during validation
            System.err.println("!!! JwtUtil Error: Unexpected error during JWT validation: " + e.getMessage());
            e.printStackTrace(); // Print stack trace for debugging
            return false;
        }
    }
} 