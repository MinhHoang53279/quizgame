const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Hàm tạo token
const generateToken = (user) => {
    return jwt.sign(
        {userId: user._id, email: user.email, role: user.role},
        process.env.JWT_SECRET,
        {expiresIn: "1h"}
    );
};

exports.register = async (req, res) => {
    try {
        const {username, email, passwordHash} = req.body;

        // Kiểm tra nếu user đã tồn tại
        let user = await User.findOne({email});

        if (user) {
            // Nếu user đã tồn tại, tự động đăng nhập
            const token = generateToken(user);
            return res.json({message: "Email đã tồn tại, tự động đăng nhập", token, user});
        }

        // Mã hóa mật khẩu
        const hashedPassword = await bcrypt.hash(passwordHash, 10);

        // Tạo user mới
        user = new User({
            username,
            email,
            passwordHash: hashedPassword,
            role: "user",
        });

        await user.save();

        // Tạo token
        const token = generateToken(user);

        res.status(201).json({message: "Đăng ký thành công", token, user});
    } catch (error) {
        res.status(500).json({message: "Lỗi server", error});
    }
};

exports.login = async (req, res) => {
    try {
        const {email, password} = req.body;

        // Kiểm tra user có tồn tại không
        const user = await User.findOne({email});
        if (!user) {
            return res.status(400).json({message: "Email hoặc mật khẩu không đúng!"});
        }

        // Kiểm tra mật khẩu
        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(400).json({message: "Email hoặc mật khẩu không đúng!"});
        }

        // Tạo token
        const token = generateToken(user);

        res.json({message: "Đăng nhập thành công", token, user});
    } catch (error) {
        res.status(500).json({message: "Lỗi server", error});
    }
};
