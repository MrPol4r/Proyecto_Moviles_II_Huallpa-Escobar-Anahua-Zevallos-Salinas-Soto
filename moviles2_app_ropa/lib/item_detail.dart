// item_detail.dart
import 'package:flutter/material.dart';
import 'package:moviles2_app_ropa/catalog_data.dart';
import 'catalog_page.dart';

class ItemDetailPage extends StatelessWidget {
  static const routeName = '/detail';
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CatalogItem item =
        ModalRoute.of(context)!.settings.arguments as CatalogItem;
    final salePrice =
        item.isOnSale
            ? item.price * (1 - item.discountPercent / 100)
            : item.price;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(item.imageUrl, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (item.isOnSale)
                    Row(
                      children: [
                        Text(
                          'S/ ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'S/ ${salePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'S/ ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 20,
                          color:
                              i < item.rating.round()
                                  ? Colors.amber
                                  : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.reviewCount} reseñas',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Agregar al carrito'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
