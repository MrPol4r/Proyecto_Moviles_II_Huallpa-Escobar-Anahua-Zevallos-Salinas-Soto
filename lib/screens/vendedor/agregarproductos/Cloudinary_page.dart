import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'deplztfl0';
  final String uploadPreset = 'ml_default'; // Ya lo tienes creado en Cloudinary
  final picker = ImagePicker();

  // 1. Selección de imagen
  Future<File?> seleccionarImagen() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // compresión (opcional para reducir peso)
    );
    return picked != null ? File(picked.path) : null;
  }

  // 2. Subida de imagen a Cloudinary
  Future<String?> subirImagen(File image) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = json.decode(resBody);
        return data['secure_url']; // URL segura de Cloudinary
      } else {
        print('⚠️ Error al subir: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Excepción al subir imagen: $e');
      return null;
    }
  }
}
