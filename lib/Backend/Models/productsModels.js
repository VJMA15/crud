const mongoose = require("mongoose");

const productSchema = new mongoose.Schema({
    nombre: { type: String, required: true },
    precio: { type: Number, required: true },
    descripcion: { type: String, required: true },
    categoria: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model("Product", productSchema);
