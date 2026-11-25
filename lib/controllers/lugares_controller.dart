import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:flutter_application_guia_turismo/services/lugares_service.dart';
import 'package:flutter_application_guia_turismo/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  final LugaresServices _service = LugaresServices();
  List<LugaresModel> lugares = [];
  Set<int> favoritos = {};
  Map<String, String> fotosLocais = {};
  bool carregando = false;
  String erro = '';

  LugaresController() {
    _inicializar();
  }

  Future<void> _inicializar() async {
    favoritos = await SessionService.lerFavoritos();
    fotosLocais = await SessionService.lerFotosLocais();
    await listarLugares();
  }

  bool isFavorito(int id) => favoritos.contains(id);

  List<LugaresModel> get lugaresFavoritos =>
      lugares.where((l) => favoritos.contains(l.id)).toList();

  Future<void> alternarFavorito(int id) async {
    if (favoritos.contains(id)) {
      favoritos.remove(id);
    } else {
      favoritos.add(id);
    }
    await SessionService.salvarFavoritos(favoritos);
    notifyListeners();
  }

  String? obterFotoLugar(LugaresModel lugar) {
    if (lugar.imagem != null && lugar.imagem!.isNotEmpty) {
      return lugar.imagem;
    }
    return fotosLocais[lugar.nome.toLowerCase().trim()];
  }

  Future<void> listarLugares() async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final token = await SessionService.lerToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          "Faça login na API (e-mail e senha) na tela de conta para carregar os lugares.",
        );
      }
      lugares = await _service.listarLugares(token);
    } catch (e) {
      erro = e.toString().replaceAll("Exception: ", '');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrarLugar(
    LugaresModel lugar, {
    String? caminhoFotoLocal,
  }) async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      final token = await SessionService.lerToken();
      if (token == null || token.isEmpty) {
        throw Exception("Faça login na API para cadastrar lugares!");
      }
      await _service.cadastrarLugar(lugar, token);

      if (caminhoFotoLocal != null && caminhoFotoLocal.isNotEmpty) {
        await SessionService.salvarFotoLocal(lugar.nome, caminhoFotoLocal);
        fotosLocais = await SessionService.lerFotosLocais();
      }

      await listarLugares();
      return true;
    } catch (e) {
      erro = e.toString().replaceAll("Exception: ", '');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
