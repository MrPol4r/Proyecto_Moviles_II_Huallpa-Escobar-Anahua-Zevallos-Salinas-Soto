// lib/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatelessWidget {
  CatalogScreen({super.key});

  // Ahora todos usan la imagen local
  final List<Product> products = List.generate(
    10,
    (i) => Product(
      id: 'p$i',
      name: 'Producto $i',
      price: 10.0 + i,
      // ruta al asset, no URL
      imageUrl: 'assets/images/polo.png',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, i) => ProductCard(product: products[i]),
      ),
    );
  }
}
