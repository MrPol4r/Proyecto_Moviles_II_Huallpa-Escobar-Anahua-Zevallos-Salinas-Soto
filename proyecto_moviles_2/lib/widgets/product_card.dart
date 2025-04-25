// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.network(product.imageUrl, width: 50, fit: BoxFit.cover),
        title: Text(product.name),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
        trailing: ValueListenableBuilder<Set<String>>(
          valueListenable: FavoritesService.favorites,
          builder: (context, favs, _) {
            final isFav = favs.contains(product.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                FavoritesService.toggleFavorite(product.id);
              },
            );
          },
        ),
      ),
    );
  }
}
