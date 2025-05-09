import 'package:flutter/material.dart';

class Variante {
  final String nombre;
  final double precio;
  int stock;

  Variante({required this.nombre, this.precio = 0.0, this.stock = 0});
}

class VariantesPage extends StatefulWidget {
  const VariantesPage({super.key, required List variantes});

  @override
  State<VariantesPage> createState() => _VariantesPageState();
}

class _VariantesPageState extends State<VariantesPage> {
  List<Variante> variantes = [];
  final TextEditingController nombreController = TextEditingController();

  void _agregarVariante(String nombre) {
    setState(() {
      variantes.add(Variante(nombre: nombre));
    });
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Variante'),
          content: TextField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre (ej: M / Rojo)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nombreController.clear();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = nombreController.text.trim();
                if (nombre.isNotEmpty) {
                  _agregarVariante(nombre);
                  Navigator.pop(context);
                  nombreController.clear();
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

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
            onPressed: _mostrarDialogoAgregar,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body:
          variantes.isEmpty
              ? const Center(child: Text('No hay variantes disponibles'))
              : ListView.builder(
                itemCount: variantes.length,
                itemBuilder: (context, index) {
                  final variante = variantes[index];
                  return ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: Text(variante.nombre),
                    subtitle: Text(
                      'PEN ${variante.precio.toStringAsFixed(2)}  •  Disponibles: ${variante.stock}',
                    ),
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
