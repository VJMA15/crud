import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Asegúrate de que esta ruta sea correcta

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  List<String> categories = [];
  String selectedCategory = "Todas";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      List<dynamic> products = await apiService.getProducts();
      Set<String> uniqueCategories = {"Todas"};

      for (var product in products) {
        if (product["categoria"] != null) {
          uniqueCategories.add(product["categoria"]);
        }
      }

      setState(() {
        allProducts = products;
        filteredProducts = products;
        categories = uniqueCategories.toList();
      });
    } catch (e) {
      print("Error al obtener productos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final productName = product["nombre"].toString().toLowerCase();
        final productCategory = product["categoria"] ?? "Todas";
        final matchesCategory = selectedCategory == "Todas" || productCategory == selectedCategory;
        return productName.contains(query.toLowerCase()) && matchesCategory;
      }).toList();
    });
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filterProducts(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos Disponibles')),
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterProducts,
            ),
          ),

          // 🔽 Botón expandible para categorías
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filtrar por categoría',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) filterByCategory(value);
              },
            ),
          ),

          // 📦 Lista de productos
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: Text("No hay productos disponibles"))
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(product["nombre"]),
                    subtitle: Text("Precio: \$${product["precio"]}\nCategoría: ${product["categoria"] ?? 'Sin categoría'}"),
                    leading: Icon(Icons.shopping_cart),
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
