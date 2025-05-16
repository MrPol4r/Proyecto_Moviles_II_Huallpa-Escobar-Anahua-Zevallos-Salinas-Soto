/*
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLogged = AuthService.isUserLoggedIn();

    if (!isLogged) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tus favoritos')),
      );
    }

    return const Scaffold(body: Center(child: Text('Tus productos favoritos')));
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Product>> _productsFuture;

  Future<List<Product>> _fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('producto').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = AuthService.isUserLoggedIn();

    if (!isLogged) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favoritos')),
        body: const Center(child: Text('Inicia sesión para ver tus favoritos')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar productos: ${snapshot.error}'),
            );
          }

          final allProducts = snapshot.data ?? [];

          return ValueListenableBuilder<Set<String>>(
            valueListenable: FavoritesService.favorites,
            builder: (context, favoriteIds, _) {
              final favoriteProducts =
                  allProducts.where((p) => favoriteIds.contains(p.id)).toList();

              if (favoriteProducts.isEmpty) {
                return const Center(
                  child: Text('No tienes productos favoritos.'),
                );
              }

              return ListView.builder(
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return ListTile(
                    leading:
                        product.imagenes.isNotEmpty
                            ? Image.network(
                              product.imagenes[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                            )
                            : Image.asset(
                              'assets/images/placeholder.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    title: Text(product.nombre),
                    subtitle: Text('S/ ${product.precio.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.black),
                      onPressed: () {
                        FavoritesService.toggleFavorite(product.id);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
