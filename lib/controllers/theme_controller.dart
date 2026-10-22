import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool temaEscuro = false;

  ThemeMode get temaAtual => temaEscuro ? ThemeMode.dark : ThemeMode.light;

  void alterarTema() {
    temaEscuro = !temaEscuro;
    notifyListeners();
  }
}