import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth =
      FirebaseAuth.instance; // 💡 lo marcamos como static

  // Obtener el usuario actual
  static User? get currentUser => _auth.currentUser;

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print("❌ Error de login: ${e.code} - ${e.message}");
      return false;
    }
  }

  // Registrar nuevo usuario
  Future<bool> register(
    String email,
    String password,
    String rol,
    String nombre,
    String telefono,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('usuario')
          .doc(cred.user!.uid)
          .set({
            'email': email,
            'rol': rol,
            'nombre': nombre,
            'telefono': telefono,
            'fechaRegistro': Timestamp.now(),
          });

      return true;
    } catch (e) {
      print('❌ Error al registrar: $e');
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

  // Verifica si hay sesión activa
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obtener los datos del usuario desde Firestore
  static Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuario')
            .doc(user.uid)
            .get();

    return doc.data(); // puede ser null
  }

  // Cerrar sesión
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
