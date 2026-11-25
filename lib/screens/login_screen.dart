import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/controllers/auth_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/lugares_controller.dart';
import 'package:flutter_application_guia_turismo/screens/mapa_lugares_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _abrirGuia() async {
    context.read<LugaresController>().listarLugares();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MapaLugaresScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia Explorer - Conta e Login'),
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authController.usuarioGoogle;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 42)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName ?? 'Usuário Google',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    user.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Acesso à API (Lugares)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail da API',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final senha = _senhaController.text.trim();
                    if (email.isEmpty || senha.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha e-mail e senha da API.'),
                        ),
                      );
                      return;
                    }
                    final ok = await authController.login(email, senha);
                    if (ok && context.mounted) {
                      await _abrirGuia();
                    }
                  },
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Entrar na API'),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                if (user == null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await authController.loginComGoogle();
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login com Google realizado!'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar com o Google'),
                  ),

                if (authController.temSessaoAtiva) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _abrirGuia,
                    icon: const Icon(Icons.explore),
                    label: const Text('Ir para o Guia'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      await authController.logout();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sair de todas as contas',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],

                if (authController.erro.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    authController.erro,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
