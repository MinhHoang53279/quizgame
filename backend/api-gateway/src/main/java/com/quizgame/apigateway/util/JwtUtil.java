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

@Component
public class JwtUtil {

    @Value("${jwt.secret}") // Same secret as auth-service
    private String secret;

    private Key key;

    @PostConstruct
    public void init() {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        this.key = new SecretKeySpec(keyBytes, "HmacSHA384");
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

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