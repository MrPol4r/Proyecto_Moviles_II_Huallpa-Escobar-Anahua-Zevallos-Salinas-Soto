import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await AuthService.getUserData();
    setState(() {
      _userData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isUserLoggedIn()) {
      return const Scaffold(
        body: Center(child: Text('🔒 Inicia sesión para ver tu perfil')),
      );
    }

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text('❌ No se pudo cargar el perfil.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                'assets/images/perfil.png',
              ), // opcional
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nombre'),
              subtitle: Text(_userData!['nombre'] ?? 'Sin nombre'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Correo'),
              subtitle: Text(_userData!['email'] ?? 'Sin correo'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Teléfono'),
              subtitle: Text(_userData!['telefono'] ?? 'Sin número'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
