import 'package:flutter/material.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F2FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Text("Mt", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      const Text("Mi tienda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Búsqueda',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Prepárate para vender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: const [
                    _MissionItem(text: "Agregar el primer producto"),
                    Divider(),
                    _MissionItem(text: "Personaliza tu dominio"),
                    Divider(),
                    _MissionItem(text: "Personalizar tu tienda online"),
                    Divider(),
                    _MissionItem(text: "Asignar un nombre a tu tienda"),
                    Divider(),
                    _MissionItem(text: "Revisa tus tarifas de envío"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Text(
                  "Crea el negocio de tus sueños por 1 \$ al mes\nSuscríbete para obtener 3 meses por 1 \$ al mes en los planes seleccionados.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final String text;
  const _MissionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
