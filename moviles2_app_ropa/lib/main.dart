// main.dart
import 'package:flutter/material.dart';
import 'catalog_page.dart';
import 'item_detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Ropa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CatalogPage(),
      routes: {ItemDetailPage.routeName: (context) => const ItemDetailPage()},
    );
  }
}
