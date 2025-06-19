// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:proyecto_moviles_2/services/FavoriteService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles_2/models/product.dart'; // Asegúrate de importar tu modelo Product
import 'package:proyecto_moviles_2/screens/product_detail_screen.dart'; // Para navegar al detalle

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  Stream<List<Product>>? _favoriteProductsStream;

  @override
  void initState() {
    super.initState();
    _loadFavoritesStream();
  }

  void _loadFavoritesStream() {
    if (AuthService.isUserLoggedIn()) {
      setState(() {
        _favoriteProductsStream = _getFavoriteProducts();
      });
    } else {
      setState(() {
        _favoriteProductsStream = null;
      });
    }
  }

  // Stream para obtener productos favoritos
  Stream<List<Product>> _getFavoriteProducts() {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('usuario')
        .doc(userId)
        .collection('favoritos')
        .snapshots()
        .asyncMap((favoriteSnapshot) async {
          if (favoriteSnapshot.docs.isEmpty) {
            return [];
          }

          final productIds =
              favoriteSnapshot.docs.map((doc) => doc.id).toList();

          // Firebase permite hasta 10 cláusulas 'whereIn'. Si tienes más de 10 IDs de productos,
          // necesitarás dividir la consulta en lotes o cambiar la estrategia.
          // Por ahora, asumimos que no excederás este límite para evitar complejidad.
          final productsQuerySnapshot =
              await FirebaseFirestore.instance
                  .collection('producto')
                  .where(FieldPath.documentId, whereIn: productIds)
                  .get();

          // Mapea los documentos de productos a objetos Product usando tu constructor fromMap
          return productsQuerySnapshot.docs.map((doc) {
            // Asegúrate de pasar el ID del documento y sus datos al constructor fromMap
            return Product.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  void _removeFavorite(String productId) async {
    await _favoriteService.removeFavorite(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto removido de favoritos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body:
          !AuthService.isUserLoggedIn()
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'Inicia sesión para ver tus productos favoritos.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : StreamBuilder<List<Product>>(
                stream: _favoriteProductsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No tienes productos favoritos aún.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final favoriteProducts = snapshot.data!;
                  return ListView.builder(
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading:
                              product.imagenes.isNotEmpty
                                  ? Image.network(
                                    product.imagenes[0],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.image, size: 50),
                                  )
                                  : const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                          title: Text(product.nombre),
                          subtitle: Text(
                            'S/ ${product.precio.toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFavorite(product.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailScreen(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
