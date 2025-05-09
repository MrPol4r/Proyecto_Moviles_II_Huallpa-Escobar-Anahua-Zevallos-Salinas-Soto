import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/canales_venta_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/categoria_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/descripcion_page.dart'
    show ProductDescriptionPage;
import 'package:tienda_ropas/screens/vendedor/agregarproductos/inventario_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/precio_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variantes_page.dart';

class SellerAddProductPage extends StatefulWidget {
  const SellerAddProductPage({super.key});

  @override
  State<SellerAddProductPage> createState() => _SellerAddProductPageState();
}

class _SellerAddProductPageState extends State<SellerAddProductPage> {
  String? _descripcion;
  String? _categoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Activo'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // TODO: Guardar producto
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multimedia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              dashPattern: const [6, 3],
              color: Colors.grey.shade400,
              child: Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.image, size: 40, color: Colors.blue),
                    SizedBox(height: 6),
                    Text(
                      'Agregar imágenes',
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Elige un plan para agregar más tipos de elementos multimedia',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add),
              title: Text(_descripcion ?? 'Agregar descripción'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProductDescriptionPage(
                          initialDescription: _descripcion,
                        ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _descripcion = result;
                  });
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add),
              title: Text(_categoria ?? 'Seleccionar categoría'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriaPage()),
                );
                if (result != null) {
                  setState(() {
                    _categoria = result;
                  });
                }
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_money),
              title: const Text('Poner precio'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrecioPage()),
                );
              },
            ),

            const SizedBox(height: 24),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Canales de ventas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Text(
                'Editar',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CanalesVentaPage()),
                );
              },
            ),
            const Text('Tienda online, Point of Sale'),
            const Divider(height: 32),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add),
              title: const Text('Agregar opciones (color, talla, etc.)'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VariantesPage(variantes: []),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Inventario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Text(
                'Editar',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventarioPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Disponible'),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                const Text('0'),
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
            const Divider(height: 32),

            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Envío'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Tipo'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Proveedor'),
              subtitle: Text('Mi tienda'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Etiquetas'),
            ),
          ],
        ),
      ),
    );
  }
}
