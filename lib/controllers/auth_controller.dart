import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/services/auth_service.dart';
import 'package:flutter_application_guia_turismo/services/session_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool inicializado = false;
  bool carregando = false;
  String erro = '';
  String token = '';
  User? usuarioGoogle;

  AuthController() {
    _restaurarSessao();
  }

  Future<void> _restaurarSessao() async {
    usuarioGoogle = _authService.usuarioAtual;
    token = await SessionService.lerToken() ?? '';
    inicializado = true;
    notifyListeners();
  }

  bool get estaLogadoApi => token.isNotEmpty;
  bool get estaLogadoGoogle => usuarioGoogle != null;
  bool get temSessaoAtiva => estaLogadoGoogle || estaLogadoApi;

  Future<bool> login(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      token = await _authService.login(email, senha);
      await SessionService.salvarToken(token);
      return true;
    } catch (e) {
      erro = 'Erro ao fazer login na API: $e';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> loginComGoogle() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final user = await _authService.loginComGoogle();
      if (user == null) {
        erro = 'Login com Google cancelado.';
        return false;
      }
      usuarioGoogle = user;
      return true;
    } catch (e) {
      erro = 'Erro ao entrar com Google: $e';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      token = '';
      usuarioGoogle = null;
      await _authService.logoutGoogle();
      await SessionService.limparToken();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
