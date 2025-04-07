const express = require("express");
const AuthController = require("../controllers/AuthController");

const router = express.Router();

// API đăng ký (tự động đăng nhập nếu email đã tồn tại)
router.post("/register", AuthController.register);

// API đăng nhập
router.post("/login", AuthController.login);

module.exports = router;
