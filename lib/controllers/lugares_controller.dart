import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:flutter_application_guia_turismo/services/lugares_service.dart';
import 'package:flutter_application_guia_turismo/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  final LugaresServices _service = LugaresServices();
  List<LugaresModel> lugares = [];
  bool carregando = false;
  String erro = '';

  LugaresController() {
    listarLugares();
  }

  Future<void> listarLugares() async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final token = await SessionService.lerToken();
      if(token == null || token.isEmpty) {
        throw Exception("Usuário não autenticado");
      }
      lugares = await _service.listarLugares(token);
    } catch (e) {
      erro = e.toString().replaceAll("Exception: ", '');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrarLugar(LugaresModel lugar) async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final token = await SessionService.lerToken();
      if(token == null || token.isEmpty) {
        throw Exception("Usuário não autenticado!");
      }
      await _service.cadastrarLugar(lugar, token);
      await listarLugares();
      return true;
    } catch(e) {
      erro = e.toString().replaceAll("Exception: ", '');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}