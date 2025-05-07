import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? productoExistente;

  const ProductFormScreen({super.key, this.productoExistente});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late String estadoSeleccionado;
  late TextEditingController _stockController;
  final List<String> estados = ['disponible', 'no disponible', 'inactivo'];

  @override
  void initState() {
    super.initState();
    estadoSeleccionado = widget.productoExistente?.estado ?? 'disponible';
    _stockController = TextEditingController(
      text: widget.productoExistente?.stock.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productoExistente == null
              ? 'Nuevo Producto'
              : 'Editar Producto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Estado del producto',
              ),
              items:
                  estados
                      .map(
                        (estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => estadoSeleccionado = val!),
            ),
          ],
        ),
      ),
    );
  }
}
