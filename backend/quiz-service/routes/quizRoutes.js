const express = require("express");
const router = express.Router();
const {quizzes, questions} = require("../data/mockData");

// 📌 Lấy danh sách quiz
router.get("/quizzes", (req, res) => {
    res.json(quizzes);
});

// 📌 Lấy danh sách câu hỏi của một quiz
router.get("/quizzes/:quizId/questions", (req, res) => {
    const {quizId} = req.params;
    const quizQuestions = questions.filter(q => q.quizId === quizId);
    res.json(quizQuestions);
});

// 📌 Tạo một quiz mới
router.post("/quizzes", (req, res) => {
    const {title, description} = req.body;
    const newQuiz = {id: Date.now().toString(), title, description};
    quizzes.push(newQuiz);
    res.status(201).json(newQuiz);
});

module.exports = router;
