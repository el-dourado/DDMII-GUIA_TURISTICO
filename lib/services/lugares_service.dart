import 'dart:convert';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;

class LugaresServices {
  Future<List<LugaresModel>> listarLugares(String token) async {
    final url = Uri.parse('https://guia.liliaborges.com.br/lugares');
    final resposta = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(resposta.statusCode == 200) {
      final List dados = jsonDecode(resposta.body);
      return dados.map((e) => LugaresModel.fromJson(e)).toList();
    } else {
      final erro = jsonDecode(resposta.body);
      throw Exception(erro['erro']);
    }
  }

  Future<String> cadastrarLugar(LugaresModel lugar, String token) async {
    // Trecho finalizado entre 21:05 (fim de 4_part_004.mp4) e 21:21 (início de 6_part_000.mp4).
    // Abaixo está a implementação correspondente à chamada feita em LugaresController
    // e à documentação do Swagger (POST https://guia.liliaborges.com.br/lugares -> 201):
    final url = Uri.parse('https://guia.liliaborges.com.br/lugares');
    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(lugar.toJson()),
    );

    if(resposta.statusCode == 201 || resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);
      return dados['mensagem'] ?? 'Lugar cadastrado com sucesso!';
    } else {
      final erro = jsonDecode(resposta.body);
      throw Exception(erro['erro']);
    }
  }
}