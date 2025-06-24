import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearProducto(Map<String, dynamic> producto) async {
    await _firestore.collection('productos').add(producto);
  }

  // ✅ Método para actualizar un producto existente
  Future<void> actualizarProducto(String productoId, Map<String, dynamic> data) async {
    await _firestore.collection('productos').doc(productoId).update(data);
  }
}
