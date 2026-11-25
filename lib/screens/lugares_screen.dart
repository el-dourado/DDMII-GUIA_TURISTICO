import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/controllers/gps_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/lugares_controller.dart';
import 'package:flutter_application_guia_turismo/services/acoes_lugar_service.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  bool _somenteFavoritos = false;

  ImageProvider? _resolverImagem(String? origem) {
    if (origem == null || origem.isEmpty) return null;
    if (origem.startsWith('http://') || origem.startsWith('https://')) {
      return NetworkImage(origem);
    }
    final arquivo = File(origem);
    if (arquivo.existsSync()) {
      return FileImage(arquivo);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _somenteFavoritos ? "Meus Favoritos" : "Lugares para visitar",
        ),
        actions: [
          IconButton(
            tooltip: _somenteFavoritos
                ? "Mostrar todos"
                : "Mostrar apenas favoritos",
            icon: Icon(
              _somenteFavoritos
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            onPressed: () {
              setState(() {
                _somenteFavoritos = !_somenteFavoritos;
              });
            },
          ),
          IconButton(
            tooltip: "Atualizar lista",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<LugaresController>().listarLugares(),
          ),
        ],
      ),
      body: Consumer2<LugaresController, GpsController>(
        builder: (context, lugaresController, gpsController, child) {
          if (lugaresController.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lugaresController.erro.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lugaresController.erro,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, 'login'),
                      icon: const Icon(Icons.login),
                      label: const Text("Ir para Login / Conta"),
                    ),
                  ],
                ),
              ),
            );
          }

          final lista = _somenteFavoritos
              ? lugaresController.lugaresFavoritos
              : lugaresController.lugares;

          if (lista.isEmpty) {
            return Center(
              child: Text(
                _somenteFavoritos
                    ? "Você ainda não favoritou nenhum lugar."
                    : "Nenhum lugar encontrado!",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final lugar = lista[index];
              final isFav = lugaresController.isFavorito(lugar.id);
              final distancia = gpsController.formatarDistancia(
                lugar.latitude,
                lugar.longitude,
              );
              final fotoPath = lugaresController.obterFotoLugar(lugar);
              final imageProvider = _resolverImagem(fotoPath);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.teal.shade50,
                            backgroundImage: imageProvider,
                            child: imageProvider == null
                                ? const Icon(Icons.place, color: Colors.teal)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lugar.nome,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    lugar.categoria ??
                                        "Categoria #${lugar.categoriaId}",
                                    if (distancia != null) "$distancia de você",
                                  ].join(" • "),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: isFav
                                ? "Remover dos favoritos"
                                : "Favoritar",
                            onPressed: () =>
                                lugaresController.alternarFavorito(lugar.id),
                            icon: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (lugar.descricao.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          lugar.descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                AcoesLugarService.mostrarOpcoesDeRota(
                              context,
                              lugar,
                            ),
                            icon: const Icon(Icons.directions_rounded, size: 18),
                            label: const Text("Como Chegar"),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () =>
                                AcoesLugarService.compartilharLugar(
                              lugar,
                              distancia: distancia,
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text("Compartilhar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
