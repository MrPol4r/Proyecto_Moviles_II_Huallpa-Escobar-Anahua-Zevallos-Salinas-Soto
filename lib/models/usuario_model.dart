class Usuario {
  final String id;
  final String nombre;
  final String telefono;
  final String correo;
  final String contrasena;

  Usuario({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.contrasena,
  });

  // Constructor desde Firestore
  factory Usuario.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Usuario(
      id: documentId,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      correo: data['usuario'] ?? '', // en tu Firestore el campo se llama 'usuario' pero es el correo
      contrasena: data['contrasena'] ?? '',
    );
  }

  // Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'usuario': correo,
      'contrasena': contrasena,
    };
  }
}
