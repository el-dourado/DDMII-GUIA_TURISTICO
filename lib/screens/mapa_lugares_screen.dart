import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controllers/gps_controller.dart';
import '../controllers/lugares_controller.dart';
import '../models/lugares_model.dart';

class MapaLugaresScreen extends StatefulWidget {
  const MapaLugaresScreen({super.key});

  @override
  State<MapaLugaresScreen> createState() => _MapaLugaresScreenState();
}

class _MapaLugaresScreenState extends State<MapaLugaresScreen> {
  final MapController _mapController = MapController();
  LugaresModel? _lugarSelecionado;

  // Coordenada inicial de fallback caso o GPS ainda esteja carregando (São Paulo)
  static final LatLng _centroPadrao = LatLng(-23.55052, -46.633308);

  void _exibirDetalhesLugar(BuildContext context, LugaresModel lugar) {
    setState(() {
      _lugarSelecionado = lugar;
    });

    _mapController.move(LatLng(lugar.latitude, lugar.longitude), 16.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.place_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lugar.nome,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lugar.categoria ?? "Categoria #${lugar.categoriaId}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (lugar.descricao.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  lugar.descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.explore_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    "Lat: ${lugar.latitude.toStringAsFixed(4)} | Lon: ${lugar.longitude.toStringAsFixed(4)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text("Fechar Detalhes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gpsController = context.watch<GpsController>();
    final lugaresController = context.watch<LugaresController>();

    final pontoInicial = gpsController.atual ??
        (lugaresController.lugares.isNotEmpty
            ? LatLng(lugaresController.lugares.first.latitude, lugaresController.lugares.first.longitude)
            : _centroPadrao);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.map_rounded, size: 24),
            SizedBox(width: 8),
            Text(
              "Guia Explorer",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Lista de Lugares",
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () => Navigator.pushNamed(context, 'lugares'),
          ),
          IconButton(
            tooltip: "Novo Cadastro",
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () => Navigator.pushNamed(context, 'cadastro'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pontoInicial,
              initialZoom: 13.5,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.guia',
              ),
              MarkerLayer(
                markers: [
                  // 1. PIN de Localização Atual do Usuário (GPS)
                  if (gpsController.atual != null)
                    Marker(
                      point: gpsController.atual!,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: "Você está aqui!",
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.my_location_rounded,
                              color: Colors.blueAccent,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 2. PINS dos Lugares Cadastrados na API
                  ...lugaresController.lugares.map((lugar) {
                    final isSelected = _lugarSelecionado?.id == lugar.id;
                    return Marker(
                      point: LatLng(lugar.latitude, lugar.longitude),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _exibirDetalhesLugar(context, lugar),
                        child: AnimatedScale(
                          scale: isSelected ? 1.25 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.amber[700] : Colors.teal[700],
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.place_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Indicador de Carregamento Superior
          if (lugaresController.carregando || gpsController.carregando)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        lugaresController.carregando
                            ? "Carregando lugares da API..."
                            : "Buscando sinal GPS...",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Card Inferior com Total de Pontos no Mapa
          Positioned(
            bottom: 20,
            left: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white.withOpacity(0.92),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 18, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(
                      "${lugaresController.lugares.length} lugares cadastrados",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "btnRecarregarLugares",
            backgroundColor: Colors.white,
            foregroundColor: Colors.teal,
            tooltip: "Recarregar lugares",
            onPressed: () => lugaresController.listarLugares(),
            child: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btnCentralizarGps",
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            tooltip: "Minha localização",
            onPressed: () async {
              await gpsController.buscarLocal();
              if (gpsController.atual != null) {
                _mapController.move(gpsController.atual!, 15.0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      gpsController.erro.isNotEmpty
                          ? gpsController.erro
                          : "Localização GPS não encontrada.",
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
    );
  }
}