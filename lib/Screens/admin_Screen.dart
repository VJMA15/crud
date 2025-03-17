import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> products = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  String selectedRole = "usuario";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      products = await apiService.getProducts();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener productos')),
      );
    }
  }

  Future<void> addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty || categoryController.text.isEmpty) {
      showSnackBar('Por favor, completa todos los campos');
      return;
    }

    bool success = await apiService.createProduct({
      "nombre": nameController.text,
      "precio": double.tryParse(priceController.text) ?? 0,
      "descripcion": descriptionController.text,
      "categoria": categoryController.text
    });
    if (success) {
      showSnackBar('Producto añadido exitosamente');
      fetchProducts();
    }
  }

  Future<void> addUser() async {
    if (userNameController.text.isEmpty || userEmailController.text.isEmpty || userPasswordController.text.isEmpty) {
      showSnackBar('Por favor, completa todos los campos');
      return;
    }

    bool success = await apiService.registerUser(userNameController.text, userEmailController.text, userPasswordController.text, selectedRole);
    if (success) {
      showSnackBar('Usuario registrado exitosamente');
      userNameController.clear();
      userEmailController.clear();
      userPasswordController.clear();
    }
  }

  Future<void> deleteProduct(String id) async {
    if (await apiService.deleteProduct(id)) {
      showSnackBar('Producto eliminado correctamente');
      fetchProducts();
    }
  }

  void showDialogForm(String title, List<Widget> fields, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(mainAxisSize: MainAxisSize.min, children: fields),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(onPressed: () { onConfirm(); Navigator.pop(context); }, child: Text("Guardar")),
        ],
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showEditProductDialog(String id, String nombre, String precio, String descripcion, String categoria) {
    nameController.text = nombre;
    priceController.text = precio;
    descriptionController.text = descripcion;
    categoryController.text = categoria;

    showDialogForm("Editar Producto", [
      TextField(controller: nameController, decoration: InputDecoration(labelText: "Nombre")),
      TextField(controller: priceController, decoration: InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
      TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Descripción")),
      TextField(controller: categoryController, decoration: InputDecoration(labelText: "Categoría")),
    ], () => updateProduct(id));
  }

  Future<void> updateProduct(String id) async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty || categoryController.text.isEmpty) {
      showSnackBar('⚠️ Completa todos los campos');
      return;
    }

    bool success = await apiService.updateProduct(id, {
      "nombre": nameController.text,
      "precio": double.tryParse(priceController.text) ?? 0,
      "descripcion": descriptionController.text,
      "categoria": categoryController.text
    });
    if (success) {
      showSnackBar('✅ Producto actualizado correctamente');
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel de Administrador')),
      body: Column(
        children: [
          ElevatedButton.icon(onPressed: () => showDialogForm("Añadir Producto", [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Nombre")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Descripción")),
            TextField(controller: categoryController, decoration: InputDecoration(labelText: "Categoría")),
          ], addProduct), icon: Icon(Icons.add), label: Text("Añadir Producto")),

          ElevatedButton.icon(onPressed: () => showDialogForm("Añadir Usuario", [
            TextField(controller: userNameController, decoration: InputDecoration(labelText: "Nombre")),
            TextField(controller: userEmailController, decoration: InputDecoration(labelText: "Correo Electrónico"), keyboardType: TextInputType.emailAddress),
            TextField(controller: userPasswordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            DropdownButton<String>(
              value: selectedRole,
              onChanged: (String? newValue) => setState(() => selectedRole = newValue!),
              items: ["usuario", "admin"].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            ),
          ], addUser), icon: Icon(Icons.person_add), label: Text("Añadir Usuario")),

          Expanded(
            child: products.isEmpty ? Center(child: Text("No hay productos disponibles")) :
            ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(product["nombre"]),
                    subtitle: Text("Precio: \$${product["precio"]}"),
                    leading: Icon(Icons.shopping_cart),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditProductDialog(product["_id"], product["nombre"], product["precio"].toString(), product["descripcion"], product["categoria"])),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteProduct(product["_id"])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
