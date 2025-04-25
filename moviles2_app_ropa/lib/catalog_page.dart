// catalog_page.dart
import 'package:flutter/material.dart';
import 'package:moviles2_app_ropa/catalog_data.dart';
import 'catalog_page.dart';
import 'item_detail.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = CatalogData.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Ropa')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final salePrice =
                item.isOnSale
                    ? item.price * (1 - item.discountPercent / 100)
                    : item.price;
            return GestureDetector(
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    ItemDetailPage.routeName,
                    arguments: item,
                  ),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          if (item.isOnSale)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '-${item.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.brand,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 14,
                                  color:
                                      i < item.rating.round()
                                          ? Colors.amber
                                          : Colors.grey[300],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${item.reviewCount})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (item.isOnSale)
                            Row(
                              children: [
                                Text(
                                  'S/ ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'S/ ${salePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'S/ ${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
