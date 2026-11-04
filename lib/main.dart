import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/camera_controller.dart';
import 'controllers/gps_controller.dart';
import 'controllers/lugares_controller.dart';
import 'screens/cadastro_lugar.dart';
import 'screens/lugares_screen.dart';
import 'screens/mapa_lugares_screen.dart';

void main() {
  runApp(const GuiaExplorerApp());
}

class GuiaExplorerApp extends StatelessWidget {
  const GuiaExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GpsController()),
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => CameraController()),
      ],
      child: MaterialApp(
        title: 'Guia Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B),
            primary: const Color(0xFF00695C),
            secondary: const Color(0xFFFFA000),
            surface: Colors.grey.shade50,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Color(0xFF00695C),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
            ),
          ),
        ),
        initialRoute: 'mapa',
        routes: {
          'mapa': (context) => const MapaLugaresScreen(),
          'lugares': (context) => const LugaresScreen(),
          'cadastro': (context) => const CadastroLugar(),
        },
      ),
    );
  }
}