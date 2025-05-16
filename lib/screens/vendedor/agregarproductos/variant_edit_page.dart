import 'package:flutter/material.dart';

class VariantStockPage extends StatefulWidget {
  final String varianteNombre;
  final int stockInicial;

  const VariantStockPage({
    super.key,
    required this.varianteNombre,
    required this.stockInicial,
  });

  @override
  State<VariantStockPage> createState() => _VariantStockPageState();
}

class _VariantStockPageState extends State<VariantStockPage> {
  late int _stock;

  @override
  void initState() {
    super.initState();
    _stock = widget.stockInicial;
  }

  void _guardar() {
    Navigator.pop(context, _stock);
  }

  void _aumentarStock() {
    setState(() {
      _stock++;
    });
  }

  void _disminuirStock() {
    if (_stock > 0) {
      setState(() {
        _stock--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _guardar,
        ),
        title: Text(widget.varianteNombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardar,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Disponible', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _disminuirStock,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$_stock', style: const TextStyle(fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _aumentarStock,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('Envío'),
            ),
          ],
        ),
      ),
    );
  }
}
