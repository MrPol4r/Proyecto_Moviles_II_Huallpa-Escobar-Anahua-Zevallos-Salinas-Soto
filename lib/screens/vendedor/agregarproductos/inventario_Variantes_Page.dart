import 'package:flutter/material.dart';

class InventarioVariantesPage extends StatefulWidget {
  final List<Map<String, dynamic>> variantes;

  const InventarioVariantesPage({super.key, required this.variantes});

  @override
  State<InventarioVariantesPage> createState() => _InventarioVariantesPageState();
}

class _InventarioVariantesPageState extends State<InventarioVariantesPage> {
  late List<Map<String, dynamic>> _variantes;

  @override
  void initState() {
    super.initState();
    _variantes = List<Map<String, dynamic>>.from(widget.variantes);
  }

  void _incrementarStock(int index) {
    setState(() {
      _variantes[index]['stock'] = (_variantes[index]['stock'] ?? 0) + 1;
    });
  }

  void _disminuirStock(int index) {
    setState(() {
      final stock = (_variantes[index]['stock'] ?? 0);
      if (stock > 0) {
        _variantes[index]['stock'] = stock - 1;
      }
    });
  }

  void _guardar() {
    Navigator.pop(context, _variantes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario por variantes'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _guardar,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardar,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _variantes.length,
        itemBuilder: (context, index) {
          final variante = _variantes[index];
          final nombre = variante['nombre'];
          final stock = variante['stock'] ?? 0;

          return ListTile(
            title: Text(nombre),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _disminuirStock(index),
                ),
                Text(stock.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _incrementarStock(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
