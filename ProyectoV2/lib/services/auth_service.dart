import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print("❌ Error de login: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Registrar nuevo usuario
  Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print("❌ Error de registro: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Enviar correo de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('❌ Error enviando correo de recuperación: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}
