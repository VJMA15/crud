import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_Screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    // Ocultar el teclado al hacer login
    FocusScope.of(context).unfocus();

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.23.142.46:5000/api/auth/login'),

        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": email, "password": password}),
      );

      setState(() => isLoading = false);

      print('✅ Código de respuesta: ${response.statusCode}');
      print('✅ Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('token') && data.containsKey('user')) {
          String token = data['token'] ?? '';
          String role = data['user']['rol']?.toString()?.toLowerCase()?.trim() ?? 'usuario';

          print('🔹 Datos de usuario recibidos: ${data['user']}');
          print('🔹 Rol antes de procesar: ${data['user']['rol']}');
          print('🔹 Rol después de procesar: $role');

          // Guardar en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('userRole', role);

          // Verificar si el token realmente se guardó
          String? storedToken = prefs.getString('authToken');
          if (storedToken == null || storedToken.isEmpty) {
            print("⚠️ El token no se guardó correctamente en SharedPreferences");
          } else {
            print("✅ Token guardado correctamente: $storedToken");
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Inicio de sesión exitoso')),
          );

          // Redirigir al Home con el rol
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(role: role)),
          );
        } else {
          print('⚠️ La API no devolvió los datos esperados');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: Datos incompletos en la API')),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? '❌ Error al iniciar sesión';
        print('❌ Error en el login: $errorMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('🚨 Excepción en la solicitud: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error de conexión. Inténtalo nuevamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
