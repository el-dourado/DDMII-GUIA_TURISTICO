import 'package:flutter/material.dart';
import 'package:flutter_application_guia_turismo/controllers/camera_controller.dart';
import 'package:flutter_application_guia_turismo/controllers/lugares_controller.dart';
import 'package:flutter_application_guia_turismo/models/lugares_model.dart';
import 'package:provider/provider.dart';

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

  Future<void> salvarLugar(BuildContext context) async {
    final lugaresController = Provider.of<LugaresController>(context, listen: false);

    final novoLugar = LugaresModel(
      id: 0,
      nome: nomeController.text,
      descricao: descricaoController.text,
      latitude: double.tryParse(latitudeController.text) ?? 0.0,
      longitude: double.tryParse(longitudeController.text) ?? 0.0,
      categoriaId: int.tryParse(categoriaIdController.text) ?? 1,
    );

    final sucesso = await lugaresController.cadastrarLugar(novoLugar);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? "Lugar cadastrado com sucesso!" : lugaresController.erro,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro de Lugares")),
      body: Consumer<CameraController>(
        builder: (context, controle, child) =>
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(16),
                          image: exibirImagem(controle),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => abrirModal(controle, context),
                          icon: Icon(Icons.camera_alt_rounded),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(labelText: "Nome"),
                  ),
                  TextField(
                    controller: descricaoController,
                    decoration: InputDecoration(labelText: "Descrição"),
                  ),
                  TextField(
                    controller: latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Latitude"),
                  ),
                  TextField(
                    controller: longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Longitude"),
                  ),
                  TextField(
                    controller: categoriaIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Categoria ID"),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => salvarLugar(context),
                    child: Text("Cadastrar"),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

DecorationImage exibirImagem(CameraController controle) {
  if (controle.imagemSelecionada == null) {
    return DecorationImage(
      image: NetworkImage('https://placehold.jp/150x150.png'),
    );
  } else {
    return DecorationImage(
      image: FileImage(controle.imagemSelecionada!),
      fit: BoxFit.cover,
    );
  }
}

void abrirModal(CameraController controle, context) {
  showModalBottomSheet(
    context: context,
    builder: (context) =>
      SafeArea(bottom: true,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              onTap: () {
                controle.abrirCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              onTap: () {
                controle.abrirGaleria();
                Navigator.pop(context);
              },
            ),
          ],
        )
      ),
  );
}