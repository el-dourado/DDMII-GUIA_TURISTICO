//image_picker
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> chamarGaleria() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    return imagem != null ? File(imagem.path) : null;
  }

  Future<File?> chamarCamera() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    return imagem != null ? File(imagem.path) : null;
  }
}