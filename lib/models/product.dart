// models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final double precio;
  final int descuento;
  final String descripcion;
  final double valoracion;
  final int valoracionesTotal;
  final int vendidos;
  final List<String> imagenes; // máx. 7 imágenes locales
  final List<String> colores;
  final Map<String, String> colorImagenes; // ← nuevo campo
  final List<String> tallas;
  final String descripcionTallas;
  final List<Map<String, dynamic>>
  comentarios; // Mantendremos este campo, pero con una aclaración.
  final String estado;
  final int stock;
  final String categoria;
  final String? idVendedor; // <--- ¡NUEVO CAMPO AQUÍ!

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descuento,
    required this.descripcion,
    required this.valoracion,
    required this.valoracionesTotal,
    required this.vendidos,
    required this.imagenes,
    required this.colores,
    required this.colorImagenes,
    required this.tallas,
    required this.descripcionTallas,
    required this.comentarios,
    required this.categoria,
    required this.estado,
    required this.stock,
    this.idVendedor,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      descuento: data['descuento'] ?? 0,
      descripcion: data['descripcion'] ?? '',
      valoracion: (data['valoracion'] ?? 0).toDouble(),
      // **IMPORTANTE**: Asegúrate de que en Firestore el campo sea 'valoracionesTotal'
      // Si en Firestore es 'valoraciones_total', cámbialo a 'valoracionesTotal' o ajusta esta línea:
      valoracionesTotal:
          data['valoracionesTotal'] ?? 0, // <--- Ajuste para consistencia
      vendidos: data['vendidos'] ?? 0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      colores: List<String>.from(data['colores'] ?? []),
      colorImagenes: Map<String, String>.from(data['colorImagenes'] ?? {}),
      tallas: List<String>.from(data['tallas'] ?? []),
      // **IMPORTANTE**: Asegúrate de que en Firestore el campo sea 'descripcionTallas'
      // Si en Firestore es 'descripcion_tallas', cámbialo a 'descripcionTallas' o ajusta esta línea:
      descripcionTallas:
          data['descripcionTallas'] ?? '', // <--- Ajuste para consistencia
      // Nota: El campo 'comentarios' aquí solo contendrá los comentarios si están directamente anidados en el documento del producto.
      // Si los comentarios están en una subcolección, este campo será irrelevante para esa lectura.
      comentarios: List<Map<String, dynamic>>.from(data['comentarios'] ?? []),
      categoria: data['categoria'] ?? 'Sin categoría',
      estado: data['estado'] ?? 'disponible',
      stock: data['stock'] ?? 0,
      idVendedor: data['idVendedor'], // <--- ¡Mapea desde Firestore!
    );
  }

  // **** MÉTODO fromFirestore: AGREGADO ****
  factory Product.fromFirestore(DocumentSnapshot doc) {
    // Convierte el DocumentSnapshot a un Map y luego usa tu fromMap existente.
    // Esto asegura que la lógica de mapeo se mantiene en un solo lugar.
    return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    final map = {
      'nombre': nombre,
      'precio': precio,
      'descuento': descuento,
      'descripcion': descripcion,
      'valoracion': valoracion,
      'valoracionesTotal': valoracionesTotal, // <--- Exporta con este nombre
      'vendidos': vendidos,
      'imagenes': imagenes,
      'colores': colores,
      'colorImagenes': colorImagenes,
      'tallas': tallas,
      'descripcionTallas': descripcionTallas, // <--- Exporta con este nombre
      'comentarios': comentarios, // Se exportará si no lo quitas
      'categoria': categoria,
      'estado': estado,
      'stock': stock,
      'idVendedor': idVendedor,
    };
    return map;
  }

  // **** MÉTODO copyWith: MANTENIDO Y COMPLETO ****
  Product copyWith({
    String? id,
    String? nombre,
    double? precio,
    int? descuento,
    String? descripcion,
    double? valoracion,
    int? valoracionesTotal,
    int? vendidos,
    List<String>? imagenes,
    List<String>? colores,
    Map<String, String>? colorImagenes,
    List<String>? tallas,
    String? descripcionTallas,
    List<Map<String, dynamic>>? comentarios,
    String? estado,
    int? stock,
    String? categoria,
    String? idVendedor,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      descuento: descuento ?? this.descuento,
      descripcion: descripcion ?? this.descripcion,
      valoracion: valoracion ?? this.valoracion,
      valoracionesTotal: valoracionesTotal ?? this.valoracionesTotal,
      vendidos: vendidos ?? this.vendidos,
      imagenes: imagenes ?? this.imagenes,
      colores: colores ?? this.colores,
      colorImagenes: colorImagenes ?? this.colorImagenes,
      tallas: tallas ?? this.tallas,
      descripcionTallas: descripcionTallas ?? this.descripcionTallas,
      comentarios: comentarios ?? this.comentarios,
      estado: estado ?? this.estado,
      stock: stock ?? this.stock,
      categoria: categoria ?? this.categoria,
      idVendedor: idVendedor ?? this.idVendedor,
    );
  }
}
