import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('producto').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: FutureBuilder<List<Product>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, i) => _buildProductCard(context, products[i]),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final precioConDescuento = product.precio * (1 - product.descuento / 100);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Image.asset(
          product.imagenes.isNotEmpty
              ? product.imagenes[0]
              : 'assets/images/placeholder.png',
          width: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          product.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'S/ ${precioConDescuento.toStringAsFixed(2)}  (Antes: S/ ${product.precio.toStringAsFixed(2)})',
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < product.valoracion.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            Text(
              '${product.vendidos} vendidos',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Producto "${product.nombre}" agregado al carrito (simulado)',
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }
}
