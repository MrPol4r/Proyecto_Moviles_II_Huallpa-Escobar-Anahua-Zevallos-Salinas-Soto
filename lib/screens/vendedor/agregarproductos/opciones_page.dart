import 'package:flutter/material.dart';
import 'opcion_detalle_page.dart';

class OpcionesPage extends StatefulWidget {
  final List<Map<String, List<String>>> opcionesIniciales;

  const OpcionesPage({super.key, required this.opcionesIniciales});

  @override
  State<OpcionesPage> createState() => _OpcionesPageState();
}

class _OpcionesPageState extends State<OpcionesPage> {
  late List<Map<String, List<String>>> opciones;

  @override
  void initState() {
    super.initState();
    opciones = List<Map<String, List<String>>>.from(widget.opcionesIniciales);
  }

  void _agregarOEditarOpcion({int? index}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpcionDetallePage(
          nombreInicial: index != null ? opciones[index].keys.first : null,
          valoresIniciales: index != null ? opciones[index].values.first : null,
        ),
      ),
    );

    if (resultado != null && resultado is Map<String, List<String>>) {
      setState(() {
        if (index != null) {
          opciones[index] = resultado;
        } else {
          opciones.add(resultado);
        }
      });
    }
  }

  void _eliminarOpcion(int index) {
    setState(() {
      opciones.removeAt(index);
    });
  }

  void _guardar() {
    Navigator.pop(context, opciones);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _guardar,
        ),
      ),
      body: opciones.isEmpty
          ? const Center(child: Text('No hay opciones agregadas'))
          : ListView.builder(
              itemCount: opciones.length,
              itemBuilder: (_, index) {
                final opcion = opciones[index];
                final nombre = opcion.keys.first;
                final valores = opcion[nombre]!;

                return ListTile(
                  leading: const Icon(Icons.drag_handle),
                  title: Text(nombre),
                  subtitle: Text(valores.join(', ')),
                  onTap: () => _agregarOEditarOpcion(index: index),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarOpcion(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarOEditarOpcion,
        child: const Icon(Icons.add),
      ),
    );
  }
}
