const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
    username: {type: String, required: true},
    email: {type: String, required: true, unique: true},
    passwordHash: {type: String, required: true},
    role: {type: String, default: "user"}
});

module.exports = mongoose.model("User", UserSchema);
