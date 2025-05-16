import 'package:flutter/material.dart';

class OpcionDetallePage extends StatefulWidget {
  final String? nombreInicial;
  final List<String>? valoresIniciales;

  const OpcionDetallePage({
    super.key,
    this.nombreInicial,
    this.valoresIniciales,
  });

  @override
  State<OpcionDetallePage> createState() => _OpcionDetallePageState();
}

class _OpcionDetallePageState extends State<OpcionDetallePage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nuevoValorController = TextEditingController();
  final List<String> _valores = [];

  @override
  void initState() {
    super.initState();
    if (widget.nombreInicial != null) {
      _nombreController.text = widget.nombreInicial!;
    }
    if (widget.valoresIniciales != null) {
      _valores.addAll(widget.valoresIniciales!);
    }
  }

  void _agregarValor() {
    final valor = _nuevoValorController.text.trim();
    if (valor.isNotEmpty && !_valores.contains(valor)) {
      setState(() {
        _valores.add(valor);
        _nuevoValorController.clear();
      });
    }
  }

  void _eliminarValor(int index) {
    setState(() {
      _valores.removeAt(index);
    });
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty || _valores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe ingresar un nombre y al menos un valor.')),
      );
      return;
    }
    Navigator.pop(context, {nombre: _valores});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opción'),
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
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Valores', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _valores.isEmpty
                  ? const Center(child: Text('Agrega al menos un valor'))
                  : ListView.builder(
                      itemCount: _valores.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_valores[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarValor(index),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nuevoValorController,
                    decoration: const InputDecoration(
                      labelText: 'Agregar valor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _agregarValor,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
