import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearProducto(Map<String, dynamic> producto) async {
    await _firestore.collection('productos').add(producto);
  }
}