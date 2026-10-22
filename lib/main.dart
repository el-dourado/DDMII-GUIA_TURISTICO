import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/controllers/auth_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/camera_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/lugares_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/theme_controller.dart';
import 'package:flutter_application_guia_turismo/screens/cadastro_lugar.dart';
import 'package:flutter_application_guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => CameraController()),
      ],
      child:
      // Consumer<ThemeController>(
      //   builder: (context, lugaresController, child) =>
          MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: 'cadastro',
            routes: {
              'lugares': (context) => LugaresScreen(),
              'cadastro': (context) => CadastroLugar()
            },
          ),
      // ),
    );
  }
}