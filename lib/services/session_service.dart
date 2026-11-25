import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _chaveToken = 'token';
  static const String _chaveFavoritos = 'favoritos_lugares';
  static const String _chaveFotosLocais = 'fotos_locais_lugares';

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
  }

  static Future<String?> lerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveToken);
  }

  static Future<void> limparToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
  }

  static Future<void> salvarFavoritos(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _chaveFavoritos,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<Set<int>> lerFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chaveFavoritos) ?? [];
    return lista.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  static Future<void> salvarFotoLocal(String chaveLugar, String caminho) async {
    final prefs = await SharedPreferences.getInstance();
    final mapa = await lerFotosLocais();
    mapa[chaveLugar.toLowerCase().trim()] = caminho;
    await prefs.setString(_chaveFotosLocais, jsonEncode(mapa));
  }

  static Future<Map<String, String>> lerFotosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chaveFotosLocais);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }
}
