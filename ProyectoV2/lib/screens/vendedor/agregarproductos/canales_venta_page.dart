import 'package:flutter/material.dart';

class CanalesVentaPage extends StatefulWidget {
  const CanalesVentaPage({super.key});

  @override
  State<CanalesVentaPage> createState() => _CanalesVentaPageState();
}

class _CanalesVentaPageState extends State<CanalesVentaPage> {
  bool tiendaOnline = true;
  bool pointOfSale = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canales de ventas'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Guardar canales seleccionados
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckboxListTile(
            value: tiendaOnline,
            title: const Text('Tienda online'),
            onChanged: (value) {
              setState(() {
                tiendaOnline = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            secondary: tiendaOnline
                ? const Text(
                    'Programar disponibilidad',
                    style: TextStyle(color: Colors.blue),
                  )
                : null,
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: pointOfSale,
            title: const Text('Point of Sale'),
            onChanged: (value) {
              setState(() {
                pointOfSale = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
