import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/services/auth_service.dart';
import 'package:flutter_application_guia_turismo/services/session_service.dart';

class AuthController extends ChangeNotifier {
  bool carregando = false;
  String erro = '';
  String token = '';

  Future<bool> login(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final authService = AuthService();
      token = await authService.login(email, senha);
      await SessionService.salvarToken(token);
      return true;
    } catch (e) {
      erro = 'Erro ao fazer login: $e';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = '';
    await SessionService.limparToken();
    notifyListeners();
  }
}