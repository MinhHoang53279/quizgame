const UserRepository = require("../repositories/UserRepository");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

class AuthService {
    async register(userData) {
        const existingUser = await UserRepository.findUserByEmail(userData.email);
        if (existingUser) throw new Error("Email đã tồn tại");

        userData.passwordHash = await bcrypt.hash(userData.passwordHash, 10);
        return await UserRepository.createUser(userData);
    }

    async login(email, password) {
        const user = await UserRepository.findUserByEmail(email);
        if (!user) throw new Error("Người dùng không tồn tại");

        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) throw new Error("Sai mật khẩu");

        const token = jwt.sign({userId: user._id, email: user.email}, process.env.JWT_SECRET, {expiresIn: "1h"});

        return {token, user};
    }
}

module.exports = new AuthService();
