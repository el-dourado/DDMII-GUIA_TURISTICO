import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AcoesLugarService {
  static Future<void> abrirNoGoogleMaps(LugaresModel lugar) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${lugar.latitude},${lugar.longitude}&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> abrirNoWaze(LugaresModel lugar) async {
    final uri = Uri.parse(
      'https://waze.com/ul?ll=${lugar.latitude},${lugar.longitude}&navigate=yes',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static void mostrarOpcoesDeRota(BuildContext context, LugaresModel lugar) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Como chegar com:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_rounded, color: Colors.teal),
              title: const Text('Google Maps'),
              onTap: () async {
                Navigator.pop(ctx);
                await abrirNoGoogleMaps(lugar);
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation_rounded, color: Colors.blue),
              title: const Text('Waze'),
              onTap: () async {
                Navigator.pop(ctx);
                await abrirNoWaze(lugar);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> compartilharLugar(
    LugaresModel lugar, {
    String? distancia,
  }) async {
    final linkMapa =
        'https://www.google.com/maps/search/?api=1&query=${lugar.latitude},${lugar.longitude}';

    final linhas = <String>[
      'Confira este ponto turístico no Guia Explorer!',
      '',
      'Local: ${lugar.nome}',
      if (lugar.categoria != null && lugar.categoria!.isNotEmpty)
        'Categoria: ${lugar.categoria}',
      if (lugar.descricao.isNotEmpty) 'Descrição: ${lugar.descricao}',
      if (distancia != null && distancia.isNotEmpty) 'Distância: $distancia',
      '',
      'Ver no mapa: $linkMapa',
    ];

    await SharePlus.instance.share(
      ShareParams(
        text: linhas.join('\n'),
        subject: 'Guia Explorer - ${lugar.nome}',
      ),
    );
  }
}
