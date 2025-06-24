import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tienda_ropas/routes/app_routes.dart';
import 'package:tienda_ropas/screens/vendedor/editar_stock/editar_product_page.dart'; // Asegúrate que esté correcto

class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({super.key});

  @override
  State<SellerProductsPage> createState() => _SellerProductsPageState();
}

class _SellerProductsPageState extends State<SellerProductsPage> {
  late Future<List<Map<String, dynamic>>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _obtenerProductosDelVendedor();
  }

  Future<List<Map<String, dynamic>>> _obtenerProductosDelVendedor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('productos')
        .where('vendedor_id', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _recargarProductos() async {
    final nuevosProductos = await _obtenerProductosDelVendedor();
    setState(() {
      _productosFuture = Future.value(nuevosProductos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.sellerAddProduct)
                  .then((_) => _recargarProductos());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset('assets/img/img1.png', height: 120, errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                  const SizedBox(height: 24),
                  const Text('Agrega tus productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Para empezar a vender en tu tienda, migra tus productos o consigue otros nuevos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.sellerAddProduct)
                            .then((_) => _recargarProductos());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Agregar productos'),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final variantes = List<Map<String, dynamic>>.from(producto['variantes'] ?? []);
              final stockTotal = variantes.fold<int>(0, (sum, v) => sum + (v['stock'] as int? ?? 0));

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: producto['imagen'] != null
                        ? Image.network(producto['imagen'], width: 60, height: 60, fit: BoxFit.cover)
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  title: Text(
                    producto['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Stock total: $stockTotal', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarProductPage(producto: producto),
                      ),
                    );
                    _recargarProductos();
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
