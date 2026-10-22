import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _chaveToken = 'token';

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
}