import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Image.asset(
          product.imagen,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(product.nombre),
        subtitle: Text('S/ ${product.precio.toStringAsFixed(2)}'),
      ),
    );
  }
}
