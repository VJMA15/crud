const User = require("../Models/usersModels");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// 🔹 Registrar usuario
const registerUser = async (req, res) => {
    try {
        console.log("📩 Recibida solicitud de registro:", req.body);

        const { rol, nombre, correo, password } = req.body;

        // ✅ Validar que todos los campos estén completos
        if (!rol || !nombre || !correo || !password) {
            return res.status(400).json({ message: "⚠️ Todos los campos son obligatorios" });
        }

        // ✅ Validar que el rol sea correcto
        if (!["admin", "usuario"].includes(rol.toLowerCase())) {
            return res.status(400).json({ message: "⚠️ Rol inválido. Debe ser 'admin' o 'usuario'." });
        }

        // ✅ Validar formato de correo electrónico
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(correo)) {
            return res.status(400).json({ message: "⚠️ Correo electrónico inválido." });
        }

        // ✅ Validar longitud de contraseña
        if (password.length < 6) {
            return res.status(400).json({ message: "⚠️ La contraseña debe tener al menos 6 caracteres." });
        }

        // ✅ Verificar si el usuario ya existe
        let user = await User.findOne({ correo });
        if (user) return res.status(400).json({ message: "⚠️ El usuario ya existe" });

        // 🔹 Hashear la contraseña
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 🔹 Guardar usuario
        user = new User({ rol, nombre, correo, password: hashedPassword });
        await user.save();

        console.log("✅ Usuario registrado:", { id: user._id, nombre, correo, rol });

        res.status(201).json({
            message: "✅ Usuario registrado correctamente",
            user: { id: user._id, nombre, correo, rol }
        });

    } catch (error) {
        console.error("❌ Error en el registro:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Iniciar sesión
const loginUser = async (req, res) => {
    try {
        console.log("🔑 Iniciando sesión con:", req.body);

        const { correo, password } = req.body;

        // ✅ Verificar si el usuario existe
        const user = await User.findOne({ correo });
        if (!user) return res.status(400).json({ message: "⚠️ Usuario no encontrado" });

        // ✅ Verificar contraseña
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: "⚠️ Contraseña incorrecta" });

        // 🔹 Generar el token con el rol incluido
        const token = jwt.sign(
            { id: user._id, rol: user.rol.toLowerCase() }, // 🔥 Convertimos a minúsculas para evitar errores
            process.env.JWT_SECRET || "secreto",
            { expiresIn: "1h" }
        );

        console.log("✅ Sesión iniciada. Usuario:", { id: user._id, nombre: user.nombre, rol: user.rol });

        // 🔹 Devolver el token y los datos del usuario
        res.json({
            message: "✅ Inicio de sesión exitoso",
            token,
            user: {
                id: user._id,
                nombre: user.nombre,
                correo: user.correo,
                rol: user.rol.toLowerCase() // 🔥 Ahora el rol siempre se devuelve en minúsculas
            }
        });

    } catch (error) {
        console.error("❌ Error en el login:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Obtener todos los usuarios (Solo para administradores)
const getUsers = async (req, res) => {
    try {
        console.log("📥 Obteniendo lista de usuarios...");
        const users = await User.find().select("-password"); // Excluir la contraseña
        res.json(users);
    } catch (error) {
        console.error("❌ Error al obtener usuarios:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Exportar funciones
module.exports = { registerUser, loginUser, getUsers };
