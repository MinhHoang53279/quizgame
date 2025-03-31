const express = require("express");
const cors = require("cors");
const quizRoutes = require("./routes/quizRoutes");

const app = express();
app.use(express.json());
app.use(cors());

app.use("/api", quizRoutes);

const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
    console.log(`✅ Quiz Service đang chạy tại cổng ${PORT}`);
});
