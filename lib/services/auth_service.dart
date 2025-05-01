import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static Future<bool> signIn(String email, String password) async {
    try {
      final usuarios = FirebaseFirestore.instance.collection('usuario');

      final resultado =
          await usuarios
              .where('usuario', isEqualTo: email)
              .where('contrasena', isEqualTo: password)
              .get();

      return resultado.docs.isNotEmpty;
    } catch (e) {
      print('Error al autenticar: $e');
      return false;
    }
  }
}
