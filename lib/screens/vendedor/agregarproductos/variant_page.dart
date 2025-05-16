import 'package:flutter/material.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variant_edit_page.dart';

class VariantesPage extends StatefulWidget {
  final List<Map<String, List<String>>> opciones;
  final List<Map<String, dynamic>> variantesIniciales;

  const VariantesPage({
    super.key,
    required this.opciones,
    required this.variantesIniciales,
  });

  @override
  State<VariantesPage> createState() => _VariantesPageState();
}

class _VariantesPageState extends State<VariantesPage> {
  final Map<String, int> _stockPorVariante = {};

  @override
  void initState() {
    super.initState();

    // Cargar stocks previos si existen
    for (var variante in widget.variantesIniciales) {
      final nombre = variante['nombre'];
      final stock = variante['stock'] ?? 0;
      if (nombre is String) {
        _stockPorVariante[nombre] = stock;
      }
    }
  }

  List<Map<String, String>> _generarCombinaciones() {
    if (widget.opciones.isEmpty) return [];

    List<Map<String, String>> combinaciones = [{}];

    for (final opcion in widget.opciones) {
      final nombre = opcion.keys.first;
      final valores = opcion[nombre]!;

      final nuevasCombinaciones = <Map<String, String>>[];
      for (final combinacion in combinaciones) {
        for (final valor in valores) {
          final nueva = Map<String, String>.from(combinacion);
          nueva[nombre] = valor;
          nuevasCombinaciones.add(nueva);
        }
      }
      combinaciones = nuevasCombinaciones;
    }

    return combinaciones;
  }

  List<Map<String, dynamic>> _construirVariantesConStock(List<Map<String, String>> combinaciones) {
    return combinaciones.map((combinacion) {
      final nombre = combinacion.entries.map((e) => e.value).join(' / ');
      return {
        'nombre': nombre,
        'atributos': combinacion,
        'stock': _stockPorVariante[nombre] ?? 0,
      };
    }).toList();
  }

  void _guardarVariantes() {
    final combinaciones = _generarCombinaciones();
    final variantesFinales = _construirVariantesConStock(combinaciones);
    Navigator.pop(context, variantesFinales);
  }

  @override
  Widget build(BuildContext context) {
    final combinaciones = _generarCombinaciones();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Variantes generadas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _guardarVariantes,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardarVariantes,
          ),
        ],
      ),
      body: combinaciones.isEmpty
          ? const Center(child: Text('No hay combinaciones disponibles'))
          : ListView.builder(
              itemCount: combinaciones.length,
              itemBuilder: (_, index) {
                final combinacion = combinaciones[index];
                final nombre = combinacion.entries.map((e) => e.value).join(' / ');
                final stock = _stockPorVariante[nombre] ?? 0;

                return ListTile(
                  title: Text(nombre),
                  subtitle: Text('Disponibles: $stock'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final nuevoStock = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VariantStockPage(
                          varianteNombre: nombre,
                          stockInicial: stock,
                        ),
                      ),
                    );

                    if (nuevoStock != null) {
                      setState(() {
                        _stockPorVariante[nombre] = nuevoStock;
                      });
                    }
                  },
                );
              },
            ),
    );
  }
}
