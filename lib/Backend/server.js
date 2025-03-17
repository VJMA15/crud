const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");

dotenv.config();

const app = express();
app.use(express.json());
app.use(cors());

// Importar rutas
const productsRoutes = require("./Routes/productsRoutes");
const usersRoutes = require("./Routes/usersRoutes");
const authRoutes = require("./Routes/authRoutes");

// Definir rutas
app.use("/api/products", productsRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/auth", authRoutes);

// Ruta de prueba para verificar que el servidor está corriendo
app.get("/", (req, res) => {
  res.send("🚀 API funcionando correctamente");
});

// Conectar a MongoDB Atlas
const conectarDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ Conectado a MongoDB Atlas");
  } catch (error) {
    console.error("❌ Error al conectar a MongoDB:", error);
    process.exit(1); // Detiene el servidor si falla la conexión
  }
};

conectarDB();

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`));
