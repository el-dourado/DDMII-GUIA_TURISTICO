import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class LugaresServices {
  Future<List<LugaresModel>> listarLugares(String token) async {
    final url = Uri.parse('https://guia.liliaborges.com.br/lugares');
    final resposta = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('GET /lugares [${resposta.statusCode}]: ${resposta.body}');

    if (resposta.statusCode == 200) {
      final decoded = jsonDecode(resposta.body);

      if (decoded is List) {
        return decoded.map((e) => LugaresModel.fromJson(e)).toList();
      }

      if (decoded is Map<String, dynamic>) {
        final lista = decoded['lugares'] ??
            decoded['data'] ??
            decoded['dados'] ??
            decoded.values.firstWhere((v) => v is List, orElse: () => null);

        if (lista is List) {
          return lista.map((e) => LugaresModel.fromJson(e)).toList();
        }

        throw Exception(
          decoded['erro'] ??
              decoded['message'] ??
              decoded['mensagem'] ??
              'Resposta inesperada da API.',
        );
      }

      throw Exception('Formato de resposta inválido da API.');
    } else {
      throw Exception(_extrairErro(resposta));
    }
  }

  Future<String> cadastrarLugar(LugaresModel lugar, String token) async {
    final url = Uri.parse('https://guia.liliaborges.com.br/lugares');
    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(lugar.toJson()),
    );

    debugPrint('POST /lugares [${resposta.statusCode}]: ${resposta.body}');

    if (resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);
      if (dados is Map<String, dynamic>) {
        return dados['mensagem'] ??
            dados['message'] ??
            'Lugar cadastrado com sucesso!';
      }
      return 'Lugar cadastrado com sucesso!';
    } else {
      throw Exception(_extrairErro(resposta));
    }
  }

  String _extrairErro(http.Response resposta) {
    try {
      final erro = jsonDecode(resposta.body);
      if (erro is Map<String, dynamic>) {
        final msg = erro['erro'] ??
            erro['message'] ??
            erro['error'] ??
            erro['mensagem'];
        if (msg != null) return '(${resposta.statusCode}) $msg';
      }
    } catch (_) {}
    return 'Erro HTTP ${resposta.statusCode}: ${resposta.body}';
  }
}
