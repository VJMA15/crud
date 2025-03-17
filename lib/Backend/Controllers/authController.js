const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const User = require("../Models/usersModels"); // 🛠️ Asegúrate de que el nombre del archivo es correcto

const loginUser = async (req, res) => {
    const { correo, password } = req.body; // 📌 Usamos `correo` en lugar de `email`

    try {
        // Verificar si el usuario existe
        const user = await User.findOne({ correo });
        if (!user) {
            return res.status(400).json({ message: "❌ Usuario no encontrado" });
        }

        // Comparar contraseñas
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: "🔑 Contraseña incorrecta" });
        }

        // Crear payload del token
        const payload = {
            id: user._id,
            nombre: user.nombre,
            correo: user.correo,
            rol: user.rol
        };

        // Firmar el token con clave secreta
        if (!process.env.JWT_SECRET) {
            return res.status(500).json({ message: "🚨 Error: JWT_SECRET no definido en .env" });
        }

        const token = jwt.sign(payload, process.env.JWT_SECRET, {
            expiresIn: process.env.JWT_EXPIRES || "1h" // 🛠️ Expira en 1 hora si no se especifica en .env
        });

        res.status(200).json({
            message: "✅ Inicio de sesión exitoso",
            token,
            rol: user.rol
        });

    } catch (error) {
        console.error("🚨 Error en el login:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

module.exports = { loginUser };
