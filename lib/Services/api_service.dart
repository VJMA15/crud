import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://crud-w8in.onrender.com"; // Nueva IP
 // IP y puerto del backend

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    print('🔹 Token recuperado de SharedPreferences: $token');
    return token;
  }

  // ----------------- PRODUCTOS ----------------- //

  // 🟢 GET - Obtener todos los productos
  Future<List<dynamic>> getProducts() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("❌ No hay token almacenado");

    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Error al obtener productos');
    }
  }

  // 🔵 POST - Crear un producto
  Future<bool> createProduct(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("❌ No hay token almacenado");

    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  // 🟡 PUT - Actualizar un producto
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("❌ No hay token almacenado");

    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  // 🔴 DELETE - Eliminar un producto
  Future<bool> deleteProduct(String id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw Exception("❌ No hay token almacenado");

    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  // ----------------- AUTENTICACIÓN ----------------- //

  // 🔵 POST - Registrar un nuevo usuario
  Future<bool> registerUser(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'), // 🔹 Corregida la ruta de registro
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": name,
        "correo": email,
        "password": password,
        "rol": role
      }),
    );

    return response.statusCode == 201;
  }

  // 🔵 POST - Iniciar sesión
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'), // 🔹 Corregida la ruta de login
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": email,
        "password": password
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Guardar token en SharedPreferences con la clave correcta
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', data["token"]);
      await prefs.setString('userRole', data["user"]["rol"].toString().toLowerCase().trim());

      // Verificación extra: confirmar que el token fue almacenado correctamente
      String? storedToken = prefs.getString('authToken');
      print('✅ Token guardado correctamente: $storedToken');

      return data;
    } else {
      // Manejo de errores
      final errorData = jsonDecode(response.body);
      throw Exception(errorData["message"] ?? "❌ Error al iniciar sesión");
    }
  }

  // 🔴 Cerrar sesión
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
    print("✅ Sesión cerrada y token eliminado.");
  }
}
