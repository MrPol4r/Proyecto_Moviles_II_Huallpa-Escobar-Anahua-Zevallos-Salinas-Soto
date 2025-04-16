import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class CatalogItem {
  final String name;
  final String imageUrl;
  final double price;

  CatalogItem({
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        title: 'Catálogo de Ropa',
        items: [
          CatalogItem(
            name: 'Casaca Jean',
            imageUrl: 'https://via.placeholder.com/150x150?text=Casaca+Jean',
            price: 89.90,
          ),
          CatalogItem(
            name: 'Polo Oversize',
            imageUrl: 'images/polo.png',
            price: 59.90,
          ),
          CatalogItem(
            name: 'Pantalón Cargo',
            imageUrl: 'https://via.placeholder.com/150x150?text=Pantalon+Cargo',
            price: 109.90,
          ),
          CatalogItem(
            name: 'Zapatillas Urbanas',
            imageUrl: 'https://via.placeholder.com/150x150?text=Zapatillas',
            price: 159.90,
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final List<CatalogItem> items;

  const MyHomePage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children:
              items.map((item) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('S/ ${item.price.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
