import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/firebase_options.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/camera_controller.dart';
import 'controllers/gps_controller.dart';
import 'controllers/lugares_controller.dart';
import 'screens/cadastro_lugar.dart';
import 'screens/login_screen.dart';
import 'screens/lugares_screen.dart';
import 'screens/mapa_lugares_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GuiaExplorerApp());
}

class GuiaExplorerApp extends StatelessWidget {
  const GuiaExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
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
        home: const AuthGate(),
        routes: {
          'login': (context) => const LoginScreen(),
          'mapa': (context) => const MapaLugaresScreen(),
          'lugares': (context) => const LugaresScreen(),
          'cadastro': (context) => const CadastroLugar(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.inicializado) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return auth.temSessaoAtiva
            ? const MapaLugaresScreen()
            : const LoginScreen();
      },
    );
  }
}
