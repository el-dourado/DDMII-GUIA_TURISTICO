import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsService {
  Future<LatLng?> obterLocal() async {
    bool ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) {
      debugPrint("Serviço de localização desativado.");
      return null;
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        debugPrint("Permissão de localização negada pelo usuário.");
        return null;
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      debugPrint("Permissão de localização negada permanentemente.");
      return null;
    }

    try {
      Position posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      debugPrint("ERRO ao obter posição: $erro");
      return null;
    }
  }
}