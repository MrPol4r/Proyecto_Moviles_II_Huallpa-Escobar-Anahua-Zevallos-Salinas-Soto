import 'package:flutter/material.dart';
import 'productlistscreen.dart'; // donde está el CRUD de productos
import 'UserListScreen.dart';
import '../services/auth_service.dart'; // importa tu AuthService

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      AuthService.logout();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // puedes cambiarlo a 1 si prefieres lista
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          children: [
            _buildCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Gestionar Productos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.people,
              title: 'Gestionar Usuarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
