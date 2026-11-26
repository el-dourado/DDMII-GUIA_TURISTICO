import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://guia.liliaborges.com.br';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _extrairToken(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      final token = decoded['token'] ??
          (data is Map ? data['token'] : null) ??
          decoded['access_token'] ??
          decoded['jwt'];
      if (token != null) return token.toString();
    }
    return '';
  }

  Future<String> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );

    debugPrint('POST /login [${response.statusCode}]: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final token = _extrairToken(decoded);
      if (token.isEmpty) {
        throw Exception('API não retornou o token JWT: ${response.body}');
      }
      return token;
    } else {
      throw Exception(_extrairErro(response));
    }
  }

  Future<String?> cadastrar(String nome, String email, String senha) async {
    final rotas = ['/usuarios', '/cadastro', '/register'];
    http.Response? ultimaResposta;

    for (final rota in rotas) {
      final response = await http.post(
        Uri.parse('$baseUrl$rota'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );

      debugPrint('POST $rota [${response.statusCode}]: ${response.body}');
      ultimaResposta = response;

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final token = _extrairToken(jsonDecode(response.body));
          if (token.isNotEmpty) return token;
        } catch (_) {}
        return null;
      }

      if (response.statusCode != 404) {
        throw Exception(_extrairErro(response));
      }
    }

    throw Exception(
      ultimaResposta != null
          ? _extrairErro(ultimaResposta)
          : 'Não foi possível cadastrar na API.',
    );
  }

  String _extrairErro(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final msg = data['erro'] ??
            data['message'] ??
            data['error'] ??
            data['mensagem'];
        if (msg != null) return '(${response.statusCode}) $msg';
      }
    } catch (_) {}
    return 'Erro HTTP ${response.statusCode}: ${response.body}';
  }

  Future<User?> loginComGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    return userCredential.user;
  }

  Future<void> logoutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? get usuarioAtual => _firebaseAuth.currentUser;
}