// product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'ProductFormScreen.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart'; // <-- IMPORTA TU AUTHSERVICE

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> productos = [];
  String? _currentUserId; // Para guardar el ID del vendedor logueado

  @override
  void initState() {
    super.initState();
    _loadCurrentUserIdAndProducts(); // Carga el ID y luego los productos
  }

  // Nuevo método para cargar el ID del usuario y luego los productos
  Future<void> _loadCurrentUserIdAndProducts() async {
    _currentUserId = AuthService.currentUser?.uid;
    if (_currentUserId == null) {
      // Manejar el caso donde no hay un usuario logueado (ej. redirigir a login o mostrar mensaje)
      print('Advertencia: No hay usuario logueado en ProductListScreen.');
      setState(() {
        productos = []; // Asegurarse de que la lista esté vacía
      });
      return;
    }
    _cargarProductos(); // Ahora llama a cargarProductos
  }

  Future<void> _cargarProductos() async {
    if (_currentUserId == null) {
      // Asegurarse de que tenemos un ID de usuario antes de consultar
      print('Error: No se puede cargar productos sin un ID de vendedor.');
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('producto')
            .where(
              'idVendedor',
              isEqualTo: _currentUserId,
            ) // <-- FILTRA POR EL ID DEL VENDEDOR
            .where('estado', isNotEqualTo: 'inactivo')
            .get();

    final productosCargados =
        snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();

    setState(() => productos = productosCargados);
  }

  void _confirmarEliminacion(Product producto) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${producto.nombre}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  _eliminarProducto(producto);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _eliminarProducto(Product producto) async {
    // Asegúrate de que solo el vendedor del producto pueda eliminarlo
    if (producto.idVendedor != _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permiso para eliminar este producto.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('producto')
        .doc(producto.id)
        .update({'estado': 'inactivo'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto.nombre} fue marcado como inactivo.')),
    );

    _cargarProductos();
  }

  void _editarProducto(Product producto) async {
    // Asegúrate de que solo el vendedor del producto pueda editarlo
    if (producto.idVendedor != _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permiso para editar este producto.'),
        ),
      );
      return;
    }

    final productoEditado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(productoExistente: producto),
      ),
    );

    if (productoEditado != null) {
      // El método set ya reemplaza el documento. No necesitas el .toMap() aquí
      // porque ProductFormScreen ya lo maneja internamente al guardar.
      // Solo necesitas asegurarte de que _cargarProductos() se ejecute para refrescar la lista
      _cargarProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body:
          _currentUserId == null
              ? const Center(
                child: Text(
                  'Por favor, inicia sesión como vendedor para ver tus productos.',
                ),
              )
              : productos.isEmpty
              ? const Center(
                child: Text('No tienes productos agregados aún.'),
              ) // Mensaje si no hay productos
              : ListView.builder(
                itemCount: productos.length,
                itemBuilder: (_, i) {
                  final p = productos[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          p.imagenes.isNotEmpty
                              ? Image.network(
                                p.imagenes[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      'assets/images/placeholder.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                'assets/images/placeholder.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                    ),
                    title: Text(p.nombre),
                    subtitle: Text('Stock: ${p.stock} - Estado: ${p.estado}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarProducto(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmarEliminacion(p),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          if (_currentUserId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debes iniciar sesión para agregar productos.'),
              ),
            );
            return;
          }

          final nuevo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (nuevo != null) {
            // El set del producto ya se hace dentro de _guardarProducto en ProductFormScreen.
            // Aquí solo necesitas recargar la lista de productos
            _cargarProductos();
          }
        },
      ),
    );
  }
}
