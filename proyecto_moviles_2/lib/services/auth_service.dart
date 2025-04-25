// lib/services/auth_service.dart
class AuthService {
  /// Simula el login en 2 segundos.
  static Future<bool> signIn(String email, String pass) async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: reemplazar por FirebaseAuth cuando integres Firebase.
    return email == 'user@correo.com' && pass == 'password123';
  }
}
