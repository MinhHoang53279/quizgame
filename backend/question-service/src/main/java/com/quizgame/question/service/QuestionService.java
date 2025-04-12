package com.quizgame.question.service;

import com.quizgame.question.model.Question;
import com.quizgame.question.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class QuestionService {
    @Autowired
    private QuestionRepository questionRepository;
    
    public Question createQuestion(Question question) {
        return questionRepository.save(question);
    }
    
    public Optional<Question> updateQuestion(String id, Question question) {
        return questionRepository.findById(id)
                .map(existingQuestion -> {
                    existingQuestion.setQuestionText(question.getQuestionText());
                    existingQuestion.setOptions(question.getOptions());
                    existingQuestion.setCorrectAnswerIndex(question.getCorrectAnswerIndex());
                    existingQuestion.setCategory(question.getCategory());
                    existingQuestion.setDifficulty(question.getDifficulty());
                    return questionRepository.save(existingQuestion);
                });
    }
    
    public Optional<Question> getQuestionById(String id) {
        return questionRepository.findById(id);
    }
    
    public List<Question> getAllQuestions() {
        return questionRepository.findAll();
    }
    
    public List<Question> getQuestionsByCategory(String category) {
        return questionRepository.findByCategory(category);
    }
    
    public List<Question> getQuestionsByDifficulty(String difficulty) {
        return questionRepository.findByDifficulty(difficulty);
    }
    
    public List<Question> getQuestionsByCategoryAndDifficulty(String category, String difficulty) {
        return questionRepository.findByCategoryAndDifficulty(category, difficulty);
    }
    
    public boolean deleteQuestion(String id) {
        if (questionRepository.existsById(id)) {
            questionRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public List<Question> getRandomQuestions(int count) {
        List<Question> allQuestions = questionRepository.findAll();
        java.util.Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).toList();
    }

    public List<Question> getRandomQuestionsByCategory(String category, int count) {
        List<Question> categoryQuestions = questionRepository.findByCategory(category);
        java.util.Collections.shuffle(categoryQuestions);
        return categoryQuestions.stream().limit(count).toList();
    }

    public List<Question> getRandomQuestionsByDifficulty(String difficulty, int count) {
        List<Question> difficultyQuestions = questionRepository.findByDifficulty(difficulty);
        java.util.Collections.shuffle(difficultyQuestions);
        return difficultyQuestions.stream().limit(count).toList();
    }

    public List<Question> getRandomQuestionsByCategoryAndDifficulty(String category, String difficulty, int count) {
        List<Question> questions = questionRepository.findByCategoryAndDifficulty(category, difficulty);
        java.util.Collections.shuffle(questions);
        return questions.stream().limit(count).toList();
    }
} 