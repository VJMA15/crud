import 'package:flutter/material.dart';
import 'admin_Screen.dart';
import 'user_Screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;

  HomeScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    print('🔹 Rol recibido: $role');

    String normalizedRole = role.toLowerCase().trim();

    Widget? destinationScreen;
    String screenTitle;

    if (normalizedRole == 'admin') {
      destinationScreen = AdminScreen();
      screenTitle = "Panel de Administrador";
    } else if (normalizedRole == 'usuario') {
      destinationScreen = UserScreen();
      screenTitle = "Panel de Usuario";
    } else {
      screenTitle = "Error";
      return Scaffold(
        appBar: AppBar(title: Text(screenTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '❌ Rol desconocido: $role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(screenTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, tu rol es: $role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen!),
                );
              },
              child: Text('Ir a tu panel'),
            ),
          ],
        ),
      ),
    );
  }
}
