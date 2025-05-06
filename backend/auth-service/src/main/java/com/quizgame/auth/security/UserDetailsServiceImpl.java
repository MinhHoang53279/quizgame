package com.quizgame.auth.security;

import com.quizgame.auth.model.User;
import com.quizgame.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implement UserDetailsService để tích hợp với Spring Security.
 * Chịu trách nhiệm tải thông tin chi tiết người dùng (UserDetails) từ database dựa trên username.
 */
@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Tải thông tin UserDetails của người dùng bằng username.
     * @param username Tên đăng nhập của người dùng cần tải.
     * @return UserDetails chứa thông tin người dùng.
     * @throws UsernameNotFoundException Nếu không tìm thấy người dùng với username cung cấp.
     */
    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User Not Found with username: " + username));

        // Xây dựng đối tượng UserDetailsImpl từ đối tượng User model
        return UserDetailsImpl.build(user);
    }
} 