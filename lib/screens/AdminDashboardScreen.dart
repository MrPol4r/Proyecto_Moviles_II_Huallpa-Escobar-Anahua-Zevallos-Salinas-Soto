import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:proyecto_moviles_2/screens/productlistscreen.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
              );

              if (confirmar == true) {
                AuthService.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: AuthService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data as Map<String, dynamic>?;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👤 Bienvenido: ${userData?['nombre'] ?? userData?['email'] ?? 'Usuario'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    children: [
                      _buildCard(
                        context,
                        icon: Icons.link,
                        title: 'Conectar Mercado Pago',
                        onTap: () async {
                          final uid =
                              userData?['uid'] ?? AuthService.currentUser?.uid;

                          final uri = Uri.https(
                            'auth.mercadopago.com',
                            '/authorization',
                            {
                              'client_id': '7096633862126511',
                              'response_type': 'code',
                              'platform_id': 'mp',
                              'redirect_uri':
                                  'https://mercadopago-nx0i.onrender.com/oauth_callback',
                              'state': uid ?? '',
                            },
                          );

                          if (!await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo abrir la autorización de Mercado Pago',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      _buildCard(
                        context,
                        icon: Icons.shopping_bag,
                        title: 'Gestionar Productos',
                        onTap: () async {
                          bool tieneMetodoPago =
                              await AuthService.hasPaymentMethod();

                          if (!tieneMetodoPago) {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text(
                                      'Método de pago requerido',
                                    ),
                                    content: const Text(
                                      'Debes conectar tu cuenta de Mercado Pago antes de gestionar productos.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          final uri = Uri.https(
                                            'auth.mercadopago.com',
                                            '/authorization',
                                            {
                                              'client_id': '7096633862126511',
                                              'response_type': 'code',
                                              'platform_id': 'mp',
                                              'redirect_uri':
                                                  'https://mercadopago-nx0i.onrender.com/oauth_callback',
                                              'state':
                                                  AuthService
                                                      .currentUser
                                                      ?.uid ??
                                                  '',
                                            },
                                          );
                                          launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Text('Conectar ahora'),
                                      ),
                                    ],
                                  ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductListScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
