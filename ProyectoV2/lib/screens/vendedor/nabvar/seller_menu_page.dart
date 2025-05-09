import 'package:flutter/material.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_add_product_page%20.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_profile_page.dart';

class SellerMenuPage extends StatelessWidget {
  const SellerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Vendedor')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Agregar Producto'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerAddProductPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
