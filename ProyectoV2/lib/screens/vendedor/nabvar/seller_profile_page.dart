import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Correo no disponible',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "ID de usuario: ${user?.uid ?? 'N/A'}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuraciones"),
              onTap: () {
                // Aquí puedes agregar configuración si deseas
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
