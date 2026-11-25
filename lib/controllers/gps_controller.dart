import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/gps_service.dart';

class GpsController extends ChangeNotifier {
  final GpsService _servico = GpsService();
  LatLng? atual;
  List<LatLng> pontos = [];
  bool carregando = false;
  String erro = "";

  GpsController() {
    buscarLocal();
  }

  Future<void> buscarLocal() async {
    carregando = true;
    erro = "";
    notifyListeners();

    try {
      atual = await _servico.obterLocal();
      if (atual == null) {
        erro =
            "Não foi possível obter a localização atual. Verifique o GPS e as permissões.";
      }
    } catch (e) {
      erro = e.toString();
      debugPrint("ERRO no GpsController: $erro");
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  double? calcularDistanciaEmMetros(double lat, double lon) {
    if (atual == null) return null;
    return Geolocator.distanceBetween(
      atual!.latitude,
      atual!.longitude,
      lat,
      lon,
    );
  }

  String? formatarDistancia(double lat, double lon) {
    final metros = calcularDistanciaEmMetros(lat, lon);
    if (metros == null) return null;
    if (metros < 1000) {
      return '${metros.round()} m';
    }
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  void adicionarPonto(LatLng ponto) {
    pontos.add(ponto);
    notifyListeners();
  }

  void limparPontos() {
    pontos.clear();
    notifyListeners();
  }
}
