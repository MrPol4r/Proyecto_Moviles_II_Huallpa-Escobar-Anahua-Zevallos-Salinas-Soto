import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final String clienteNombre;
  final String estado; // Pendiente, Enviado, Entregado
  final DateTime fecha;
  final List<dynamic> items;

  Pedido({
    required this.id,
    required this.clienteNombre,
    required this.estado,
    required this.fecha,
    required this.items,
  });

  factory Pedido.fromMap(String id, Map<String, dynamic> data) {
    return Pedido(
      id: id,
      clienteNombre: data['cliente_nombre'] ?? '',
      estado: data['estado'] ?? 'Pendiente',
      fecha: (data['fecha'] as Timestamp).toDate(),
      items: data['items'] ?? [],
    );
  }
}
