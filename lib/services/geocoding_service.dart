import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResultado {
  final LatLng coordenadas;
  final String enderecoFormatado;

  GeocodingResultado({
    required this.coordenadas,
    required this.enderecoFormatado,
  });
}

class GeocodingService {
  // Documentação Nominatim: https://wiki.openstreetmap.org/wiki/Nominatim
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Busca as coordenadas geográficas (latitude e longitude) por endereço textual ou CEP.
  Future<GeocodingResultado?> buscarPorEnderecoOuCep(String consulta) async {
    final queryLimpa = consulta.trim();
    if (queryLimpa.isEmpty) return null;

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': queryLimpa,
        'format': 'json',
        'addressdetails': '1',
        'limit': '1',
      });

      // A política de uso do Nominatim EXIGE um User-Agent descritivo da aplicação
      final resposta = await http.get(
        uri,
        headers: {
          'User-Agent': 'GuiaTurismoApp/1.0 (contato@guiaturismo.com)',
          'Accept': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(resposta.body);

        if (dados.isNotEmpty) {
          final item = dados[0];
          final double? lat = double.tryParse(item['lat'].toString());
          final double? lon = double.tryParse(item['lon'].toString());
          final String displayName = item['display_name'] ?? queryLimpa;

          if (lat != null && lon != null) {
            return GeocodingResultado(
              coordenadas: LatLng(lat, lon),
              enderecoFormatado: displayName,
            );
          }
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}