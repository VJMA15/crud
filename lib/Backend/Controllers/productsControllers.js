const Product = require("../Models/productsModels");

// 🔹 Crear producto
const createProduct = async (req, res) => {
    try {
        console.log("📦 Recibida solicitud para crear producto:", req.body);

        const { nombre, precio, descripcion, categoria } = req.body;
        if (!nombre || !precio || !descripcion || !categoria) {
            return res.status(400).json({ message: "⚠️ Todos los campos son obligatorios" });
        }

        const newProduct = new Product({ nombre, precio, descripcion, categoria });
        await newProduct.save();

        console.log("✅ Producto creado:", newProduct);
        res.status(201).json({ message: "✅ Producto creado correctamente", producto: newProduct });
    } catch (error) {
        console.error("❌ Error al crear producto:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Obtener todos los productos
const getProducts = async (req, res) => {
    try {
        console.log("📥 Obteniendo lista de productos...");
        const products = await Product.find();

        if (products.length === 0) {
            return res.status(404).json({ message: "⚠️ No hay productos disponibles" });
        }

        console.log(`✅ ${products.length} productos encontrados`);
        res.json(products);
    } catch (error) {
        console.error("❌ Error al obtener productos:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Actualizar producto
const updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        console.log(`✏️ Actualizando producto con ID: ${id}`);

        const updatedProduct = await Product.findByIdAndUpdate(id, req.body, { new: true });

        if (!updatedProduct) {
            return res.status(404).json({ message: "⚠️ Producto no encontrado" });
        }

        console.log("✅ Producto actualizado:", updatedProduct);
        res.json({ message: "✅ Producto actualizado", producto: updatedProduct });
    } catch (error) {
        console.error("❌ Error al actualizar producto:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Eliminar producto
const deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        console.log(`🗑️ Eliminando producto con ID: ${id}`);

        const deletedProduct = await Product.findByIdAndDelete(id);

        if (!deletedProduct) {
            return res.status(404).json({ message: "⚠️ Producto no encontrado" });
        }

        console.log("✅ Producto eliminado:", deletedProduct);
        res.json({ message: "✅ Producto eliminado" });
    } catch (error) {
        console.error("❌ Error al eliminar producto:", error);
        res.status(500).json({ message: "❌ Error en el servidor" });
    }
};

// 🔹 Exportar las funciones
module.exports = { createProduct, getProducts, updateProduct, deleteProduct };
