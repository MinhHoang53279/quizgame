const express = require("express");
const {createProxyMiddleware} = require("http-proxy-middleware");
const cors = require("cors");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const app = express();
app.use(express.json());
app.use(cors());
app.use(morgan("dev"));

// Rate Limiting (giới hạn request)
const limiter = rateLimit({
    windowMs: 60 * 1000, // 1 phút
    max: 100, // Giới hạn 100 request/phút
});
app.use(limiter);

// Chuyển tiếp API của User Service
app.use(
    "/auth",
    createProxyMiddleware({
        target: "http://localhost:3001", // Đúng cổng của User Service chưa?
        changeOrigin: true,
        pathRewrite: {"^/auth": "/auth"}, // Kiểm tra xem có cần sửa không
    })
);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ API Gateway running on port ${PORT}`);
});
