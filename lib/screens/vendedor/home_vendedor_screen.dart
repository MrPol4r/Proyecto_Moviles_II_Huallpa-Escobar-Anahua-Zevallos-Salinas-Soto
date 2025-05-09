import 'package:flutter/material.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_add_product_page%20.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_dashboard.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_menu_page.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_orders_page.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_products_page.dart';
import 'package:tienda_ropas/screens/vendedor/nabvar/seller_profile_page.dart';

class HomeSellerScreen extends StatefulWidget {
  const HomeSellerScreen({super.key});

  @override
  State<HomeSellerScreen> createState() => _HomeSellerScreenState();
}

class _HomeSellerScreenState extends State<HomeSellerScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SellerDashboard(),
    const SellerOrdersPage(),
    const SellerProductsPage(),
    const SellerMenuPage(),
    const SellerProfilePage(),
    const SellerAddProductPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFD84315), // 🔸 naranja TrendyCart
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}
