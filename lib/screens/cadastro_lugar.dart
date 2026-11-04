import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controllers/camera_controller.dart';
import '../controllers/gps_controller.dart';
import '../controllers/lugares_controller.dart';
import '../models/lugares_model.dart';
import '../services/geocoding_service.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController categoriaIdController = TextEditingController();

  // Controlador e serviço para busca de endereço/CEP via Nominatim
  final TextEditingController buscaEnderecoController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();
  bool _buscandoEndereco = false;
  String? _enderecoConfirmado;

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    categoriaIdController.dispose();
    buscaEnderecoController.dispose();
    super.dispose();
  }

  // 1. Busca por endereço ou CEP via API Nominatim (OpenStreetMap)
  Future<void> _buscarEnderecoOuCep() async {
    final consulta = buscaEnderecoController.text.trim();
    if (consulta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um endereço ou CEP para buscar.")),
      );
      return;
    }

    setState(() {
      _buscandoEndereco = true;
      _enderecoConfirmado = null;
    });

    try {
      final resultado = await _geocodingService.buscarPorEnderecoOuCep(consulta);

      if (!mounted) return;

      if (resultado != null) {
        setState(() {
          latitudeController.text = resultado.coordenadas.latitude.toString();
          longitudeController.text = resultado.coordenadas.longitude.toString();
          _enderecoConfirmado = resultado.enderecoFormatado;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.teal,
            content: Text("Coordenadas localizadas via Nominatim com sucesso!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text("Endereço/CEP não encontrado no OpenStreetMap."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Erro na busca Nominatim: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _buscandoEndereco = false;
        });
      }
    }
  }

  // 2. Preenche latitude e longitude usando o GPS atual do dispositivo
  Future<void> _usarLocalizacaoGps() async {
    final gpsController = Provider.of<GpsController>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Obtendo localização atual pelo GPS...")),
    );

    await gpsController.buscarLocal();

    if (!mounted) return;

    if (gpsController.atual != null) {
      setState(() {
        latitudeController.text = gpsController.atual!.latitude.toString();
        longitudeController.text = gpsController.atual!.longitude.toString();
        _enderecoConfirmado = "Localização capturada pelo GPS do dispositivo";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.teal,
          content: Text("Latitude e longitude do GPS aplicadas!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            gpsController.erro.isNotEmpty
                ? gpsController.erro
                : "Não foi possível obter o sinal GPS.",
          ),
        ),
      );
    }
  }

  // 3. Salvar lugar na API REST
  Future<void> _salvarLugar(BuildContext context) async {
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe o nome do lugar.")),
      );
      return;
    }

    final lat = double.tryParse(latitudeController.text);
    final lon = double.tryParse(longitudeController.text);

    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Latitude e longitude são obrigatórias. Busque por endereço/CEP ou GPS."),
        ),
      );
      return;
    }

    final lugaresController = Provider.of<LugaresController>(context, listen: false);

    final novoLugar = LugaresModel(
      id: 0,
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      latitude: lat,
      longitude: lon,
      categoriaId: int.tryParse(categoriaIdController.text.trim()) ?? 1,
    );

    final sucesso = await lugaresController.cadastrarLugar(novoLugar);

    if (!context.mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.teal,
          content: Text("Lugar cadastrado com sucesso!"),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Erro: ${lugaresController.erro}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(latitudeController.text);
    final lon = double.tryParse(longitudeController.text);
    final temCoordenadasValidas = lat != null && lon != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Novo Ponto Turístico",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CameraController>(
        builder: (context, controle, child) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner da Foto (Câmera / Galeria)
              Stack(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                      border: Border.all(color: Colors.teal.shade200, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      image: exibirImagem(controle),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton.small(
                      heroTag: "btnCameraCadastro",
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      onPressed: () => abrirModal(controle, context),
                      child: const Icon(Icons.camera_alt_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Seção de Informações Básicas
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Lugar *",
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricaoController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoriaIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ID da Categoria (ex: 1)",
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // CARD DE GEOLOCALIZAÇÃO COM NOMINATIM & GPS
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.travel_explore_rounded, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            "Localização no Mapa (Nominatim)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Digite um endereço ou CEP para preencher a latitude e longitude automaticamente via OpenStreetMap:",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),

                      // Campo de Busca Nominatim
                      TextField(
                        controller: buscaEnderecoController,
                        onSubmitted: (_) => _buscarEnderecoOuCep(),
                        decoration: InputDecoration(
                          hintText: "Ex: Av. Paulista, SP ou 01310-100",
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _buscandoEndereco
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  tooltip: "Buscar no Nominatim",
                                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.teal),
                                  onPressed: _buscarEnderecoOuCep,
                                ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Botão Buscar GPS Atual
                      OutlinedButton.icon(
                        onPressed: _usarLocalizacaoGps,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text("Usar minha localização atual (GPS)"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade800,
                        ),
                      ),

                      // Feedback de Endereço Localizado
                      if (_enderecoConfirmado != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _enderecoConfirmado!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Campos de Coordenadas
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: "Latitude *",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: longitudeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: const InputDecoration(
                                labelText: "Longitude *",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Mini Preview do Mapa com o Ponto Selecionado
                      if (temCoordenadasValidas) ...[
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 140,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(lat, lon),
                                initialZoom: 14.0,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.guia',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lon),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.redAccent,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão Cadastrar Lugar
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _salvarLugar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text(
                    "Cadastrar Ponto Turístico",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

DecorationImage exibirImagem(CameraController controle) {
  if (controle.imagemSelecionada == null) {
    return const DecorationImage(
      image: NetworkImage('https://placehold.jp/150x150.png'),
      fit: BoxFit.cover,
    );
  } else {
    return DecorationImage(
      image: FileImage(controle.imagemSelecionada!),
      fit: BoxFit.cover,
    );
  }
}

void abrirModal(CameraController controle, BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      bottom: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Colors.teal),
            title: const Text("Tirar Foto com a Câmera"),
            onTap: () {
              controle.abrirCamera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: Colors.teal),
            title: const Text("Escolher da Galeria"),
            onTap: () {
              controle.abrirGaleria();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}