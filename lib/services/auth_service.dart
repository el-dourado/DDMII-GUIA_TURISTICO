import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String url = 'https://guia.liliaborges.com.br/login';

  Future<String> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['token'] ?? '';
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}