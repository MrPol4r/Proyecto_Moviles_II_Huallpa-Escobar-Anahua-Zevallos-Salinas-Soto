class Product {
  final String id;
  final String nombre;
  final double precio;
  final String imagen;

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagen,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      imagen: data['imagen'] ?? '',
    );
  }
}
