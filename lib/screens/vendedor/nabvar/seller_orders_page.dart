import 'package:flutter/material.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de pedidos
    final List<Map<String, dynamic>> pedidos = [
      {'id': 'P001', 'cliente': 'Juan Pérez', 'estado': 'Pendiente'},
      {'id': 'P002', 'cliente': 'Ana Torres', 'estado': 'Enviado'},
      {'id': 'P003', 'cliente': 'Carlos Lima', 'estado': 'Entregado'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos recibidos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('Pedido: ${pedido['id']}'),
              subtitle: Text('Cliente: ${pedido['cliente']}'),
              trailing: Text(pedido['estado']),
              onTap: () {
                // Acción al tocar el pedido (detalles)
              },
            ),
          );
        },
      ),
    );
  }
}
