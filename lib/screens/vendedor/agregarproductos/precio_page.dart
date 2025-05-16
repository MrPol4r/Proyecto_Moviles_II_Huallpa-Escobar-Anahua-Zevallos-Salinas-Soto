import 'package:flutter/material.dart';

class PrecioPage extends StatefulWidget {
  final String? initialPrecio;
  final String? initialComparacion;
  final String? initialCosto;
  final bool? initialCobrarImpuestos;

  const PrecioPage({
    super.key,
    this.initialPrecio,
    this.initialComparacion,
    this.initialCosto,
    this.initialCobrarImpuestos,
  });

  @override
  State<PrecioPage> createState() => _PrecioPageState();
}

class _PrecioPageState extends State<PrecioPage> {
  late TextEditingController _precioController;
  late TextEditingController _comparacionController;
  late TextEditingController _costoController;

  double margen = 0;
  double ganancia = 0;
  bool cobrarImpuestos = true;

  void _calcularMargenYGanancia() {
    final precio = double.tryParse(_precioController.text) ?? 0;
    final costo = double.tryParse(_costoController.text) ?? 0;

    setState(() {
      ganancia = precio - costo;
      margen = (precio > 0 && costo > 0) ? (ganancia / precio) * 100 : 0;
    });
  }

  @override
  void initState() {
    super.initState();

    _precioController = TextEditingController(text: widget.initialPrecio ?? '');
    _comparacionController = TextEditingController(text: widget.initialComparacion ?? '');
    _costoController = TextEditingController(text: widget.initialCosto ?? '');
    cobrarImpuestos = widget.initialCobrarImpuestos ?? true;

    _precioController.addListener(_calcularMargenYGanancia);
    _costoController.addListener(_calcularMargenYGanancia);

    WidgetsBinding.instance.addPostFrameCallback((_) => _calcularMargenYGanancia());
  }

  @override
  void dispose() {
    _precioController.dispose();
    _comparacionController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  void _guardar() {
    Navigator.pop(context, {
      'precio': _precioController.text,
      'comparacion': _comparacionController.text,
      'costo': _costoController.text,
      'margen': margen,
      'ganancia': ganancia,
      'cobrarImpuestos': cobrarImpuestos,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardar,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixText: 'PEN ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comparacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio de comparación',
                prefixText: 'PEN ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo por artículo',
                prefixText: 'PEN ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Los clientes no verán esta información.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Margen'),
                    Text('${margen.toStringAsFixed(1)}%'),
                  ],
                ),
                Column(
                  children: [
                    const Text('Ganancia'),
                    Text('PEN ${ganancia.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Cobrar impuestos sobre las ventas'),
              value: cobrarImpuestos,
              onChanged: (value) {
                setState(() {
                  cobrarImpuestos = value ?? true;
                });
              },
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Precios internacionales',
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        ),
      ),
    );
  }
}
