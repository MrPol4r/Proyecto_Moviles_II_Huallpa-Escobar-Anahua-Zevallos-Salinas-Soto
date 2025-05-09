import 'package:flutter/material.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  int stockDisponible = 0;

  void aumentarStock() {
    setState(() {
      stockDisponible++;
    });
  }

  void disminuirStock() {
    setState(() {
      if (stockDisponible > 0) stockDisponible--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Guardar el inventario actualizado
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cantidad disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: disminuirStock,
                ),
                Text(
                  '$stockDisponible',
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: aumentarStock,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Esta cantidad representa el inventario general disponible para este producto.\nSi estás utilizando variantes (como talla y color), puedes gestionarlas por separado.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
