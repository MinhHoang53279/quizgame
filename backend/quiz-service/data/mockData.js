const quizzes = [
    {id: "1", title: "Quiz về lập trình", description: "Bài kiểm tra kiến thức lập trình"}
];

const questions = [
    {
        id: "101",
        quizId: "1",
        questionText: "Node.js là gì?",
        options: [
            {text: "Ngôn ngữ lập trình", isCorrect: false},
            {text: "Môi trường runtime cho JavaScript", isCorrect: true},
            {text: "Một loại database", isCorrect: false}
        ]
    }
];

module.exports = {quizzes, questions};
