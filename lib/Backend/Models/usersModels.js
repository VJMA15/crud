const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
    rol: { type: String, required: true },
    nombre: { type: String, required: true },
    correo: { type: String, required: true, unique: true },
    password: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model("User", UserSchema);
