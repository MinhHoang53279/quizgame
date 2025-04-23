package com.quizgame.quiz.service;

import com.quizgame.quiz.dto.CreateQuizRequest;
import com.quizgame.quiz.dto.QuestionDTO;
import com.quizgame.quiz.dto.QuizQuestionDTO;
import com.quizgame.quiz.dto.SubmitAnswerRequest;
import com.quizgame.quiz.dto.StartQuizResponse;
import com.quizgame.quiz.feign.QuestionServiceClient;
import com.quizgame.quiz.feign.UserServiceClient;
import com.quizgame.quiz.dto.ScoreUpdateRequestDTO;
import com.quizgame.quiz.model.Quiz;
import com.quizgame.quiz.repository.QuizRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class QuizService {

    @Autowired
    private QuizRepository quizRepository;

    @Autowired
    private QuestionServiceClient questionServiceClient; // Inject Feign Client

    @Autowired
    private UserServiceClient userServiceClient; // Inject User Service Client

    // Tạo quiz mới
    public StartQuizResponse createQuiz(CreateQuizRequest request) {
        List<QuestionDTO> questions;

        // Gọi Question Service để lấy câu hỏi ngẫu nhiên dựa trên request
        if (request.getCategory() != null && request.getDifficulty() != null) {
            questions = questionServiceClient.getRandomQuestionsByCategoryAndDifficulty(
                    request.getCategory(), request.getDifficulty(), request.getCount());
        } else if (request.getCategory() != null) {
            questions = questionServiceClient.getRandomQuestionsByCategory(
                    request.getCategory(), request.getCount());
        } else if (request.getDifficulty() != null) {
            questions = questionServiceClient.getRandomQuestionsByDifficulty(
                    request.getDifficulty(), request.getCount());
        } else {
            questions = questionServiceClient.getRandomQuestions(request.getCount());
        }

        if (questions == null || questions.isEmpty()) {
            throw new RuntimeException("Không tìm thấy câu hỏi phù hợp.");
        }

        // Nếu randomOrder = false, sắp xếp câu hỏi theo thứ tự cố định
        if (!request.isRandomOrder()) {
            questions.sort((q1, q2) -> q1.getId().compareTo(q2.getId()));
        }

        // Tạo đối tượng Quiz mới
        Quiz quiz = new Quiz();
        quiz.setUserId(request.getUserId());
        quiz.setQuestionIds(questions.stream().map(QuestionDTO::getId).collect(Collectors.toList()));
        quiz.setAnswers(new HashMap<>()); // Khởi tạo map rỗng
        quiz.setScore(0);
        quiz.setCompleted(false);

        Quiz savedQuiz = quizRepository.save(quiz); // Lưu quiz vào DB

        // Chuyển đổi QuestionDTO thành QuizQuestionDTO (không có đáp án) để trả về client
        List<QuizQuestionDTO> quizQuestions = questions.stream()
                .map(q -> new QuizQuestionDTO(q.getId(), q.getQuestionText(), q.getOptions(), q.getCategory(), q.getDifficulty()))
                .collect(Collectors.toList());

        // Trả về StartQuizResponse chứa quizId và danh sách câu hỏi
        return new StartQuizResponse(savedQuiz.getId(), quizQuestions);
    }

    // Xử lý khi người dùng submit câu trả lời
    public int submitAnswer(SubmitAnswerRequest request) {
        Quiz quiz = quizRepository.findById(request.getQuizId())
                .orElseThrow(() -> new RuntimeException("Quiz không tồn tại: " + request.getQuizId()));

        if (quiz.isCompleted()) {
            throw new RuntimeException("Quiz đã hoàn thành.");
        }

        // Kiểm tra xem câu hỏi có thuộc quiz này không
        if (!quiz.getQuestionIds().contains(request.getQuestionId())) {
            throw new RuntimeException("Câu hỏi không thuộc quiz này.");
        }

        // Kiểm tra xem câu hỏi đã được trả lời chưa
        if (quiz.getAnswers().containsKey(request.getQuestionId())) {
             throw new RuntimeException("Câu hỏi đã được trả lời.");
        }

        // Lưu câu trả lời của người dùng
        quiz.getAnswers().put(request.getQuestionId(), request.getAnswerIndex());

        // Gọi Question Service để lấy đáp án đúng
        QuestionDTO question = questionServiceClient.getQuestionById(request.getQuestionId());
        if (question == null) {
            throw new RuntimeException("Không thể lấy thông tin câu hỏi: " + request.getQuestionId());
        }

        // Kiểm tra và cập nhật điểm quiz
        int scoreIncrement = 0;
        if (request.getAnswerIndex() == question.getCorrectAnswerIndex()) {
            scoreIncrement = 1; // Chỉ tính điểm tăng thêm
            quiz.setScore(quiz.getScore() + scoreIncrement);
        }

        // Kiểm tra xem đã trả lời hết câu hỏi chưa
        if (quiz.getAnswers().size() == quiz.getQuestionIds().size()) {
            quiz.setCompleted(true);
            System.out.println("Quiz completed! Final score for quiz " + quiz.getId() + ": " + quiz.getScore());

            // Gọi User Service để cập nhật tổng điểm
            try {
                System.out.println("Calling User Service to update score for user: " + quiz.getUserId() + " with change: " + quiz.getScore());
                ScoreUpdateRequestDTO scoreRequest = new ScoreUpdateRequestDTO(quiz.getScore());
                ResponseEntity<Void> response = userServiceClient.updateUserScore(quiz.getUserId(), scoreRequest);
                if (response.getStatusCode().is2xxSuccessful()) {
                    System.out.println("Successfully updated score for user: " + quiz.getUserId());
                } else {
                    System.err.println("Failed to update score for user: " + quiz.getUserId() + ". Status: " + response.getStatusCode());
                }
            } catch (Exception e) {
                // Xử lý lỗi khi gọi User Service (ví dụ: ghi log)
                System.err.println("Error calling User Service to update score for user: " + quiz.getUserId() + ". Error: " + e.getMessage());
                // Có thể cân nhắc retry hoặc đưa vào hàng đợi
            }
        }

        quizRepository.save(quiz);
        return quiz.getScore();
    }

    // Lấy thông tin chi tiết một quiz
    public Optional<Quiz> getQuizById(String quizId) {
        return quizRepository.findById(quizId);
    }

    // Lấy lịch sử quiz của một user
    public List<Quiz> getQuizHistory(String userId) {
        return quizRepository.findByUserId(userId);
    }
} 