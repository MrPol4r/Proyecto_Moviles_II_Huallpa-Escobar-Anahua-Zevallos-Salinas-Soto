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
  final List<String> tallas;
  final String descripcionTallas;
  final List<Map<String, dynamic>> comentarios;
  //polar
  final String categoria;

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
    required this.tallas,
    required this.descripcionTallas,
    required this.comentarios,
    //polar
    required this.categoria,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      descuento: data['descuento'] ?? 0,
      descripcion: data['descripcion'] ?? '',
      valoracion: (data['valoracion'] ?? 0).toDouble(),
      valoracionesTotal: data['valoraciones_total'] ?? 0,
      vendidos: data['vendidos'] ?? 0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      colores: List<String>.from(data['colores'] ?? []),
      tallas: List<String>.from(data['tallas'] ?? []),
      descripcionTallas: data['descripcion_tallas'] ?? '',
      comentarios: List<Map<String, dynamic>>.from(data['comentarios'] ?? []),
      //polar
      categoria: data['categoria'] ?? 'Sin categoría',
    );
  }
}
