import 'package:flutter/material.dart';

class Variante {
  final String nombre;
  final double precio;
  int stock;

  Variante({required this.nombre, this.precio = 0.0, this.stock = 0});
}

class VariantesPage extends StatefulWidget {
  const VariantesPage({super.key});

  @override
  State<VariantesPage> createState() => _VariantesPageState();
}

class _VariantesPageState extends State<VariantesPage> {
  List<Variante> variantes = [
    Variante(nombre: 'M / Rojo'),
    Variante(nombre: 'L / Rojo'),
    Variante(nombre: 'M / Verde'),
    Variante(nombre: 'L / Verde'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variantes'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Agregar nueva variante manualmente si lo deseas
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Guardar variantes
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: variantes.length,
        itemBuilder: (context, index) {
          final variante = variantes[index];
          return ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(variante.nombre),
            subtitle: Text('PEN ${variante.precio.toStringAsFixed(2)}  •  Disponibles: ${variante.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (variante.stock > 0) variante.stock--;
                    });
                  },
                ),
                Text('${variante.stock}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      variante.stock++;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
