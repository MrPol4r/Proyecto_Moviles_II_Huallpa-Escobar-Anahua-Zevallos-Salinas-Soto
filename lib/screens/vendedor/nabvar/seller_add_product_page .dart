import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/Cloudinary_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/canales_venta_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/categoria_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/descripcion_page.dart' show ProductDescriptionPage;
import 'package:tienda_ropas/screens/vendedor/agregarproductos/inventario_Variantes_Page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/inventario_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/opciones_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/precio_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variant_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variantes_page.dart';
import 'package:tienda_ropas/screens/vendedor/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerAddProductPage extends StatefulWidget {
  const SellerAddProductPage({super.key});

  @override
  State<SellerAddProductPage> createState() => _SellerAddProductPageState();
}

class _SellerAddProductPageState extends State<SellerAddProductPage> {
  String? _descripcion;
  String? _categoria;
  String? _imageUrl;
  double? _precio;
  double? _precioComparacion;
  double? _costoArticulo;
  bool _cobrarImpuestos = true;

  final TextEditingController _nombreController = TextEditingController();
  List<Map<String, List<String>>> _opciones = [];
  List<Map<String, dynamic>> _variantes = [];

  Future<void> _agregarImagen() async {
    final cloudinary = CloudinaryService();
    final image = await cloudinary.seleccionarImagen();
    if (image != null) {
      final url = await cloudinary.subirImagen(image);
      if (url != null) {
        setState(() => _imageUrl = url);
      }
    }
  }

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty || _descripcion == null || _categoria == null || _imageUrl == null || _precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    final producto = {
      'nombre': nombre,
      'descripcion': _descripcion,
      'categoria': _categoria,
      'imagen': _imageUrl,
      'precio': _precio,
      'precio_comparacion': _precioComparacion,
      'fecha': DateTime.now().toIso8601String(),
      'vendedor_id': user?.uid, // 🔥 ESTO ES CLAVE
      'variantes': _variantes,
    };

    await ProductService().crearProducto(producto);

    if (mounted) {
      Navigator.pop(context);
    }
  }

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
            onPressed: _guardarProducto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multimedia', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _agregarImagen,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                dashPattern: const [6, 3],
                color: Colors.grey.shade400,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _imageUrl != null
                      ? Image.network(_imageUrl!, height: 100)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image, size: 40, color: Colors.blue),
                            SizedBox(height: 6),
                            Text('Agregar imágenes', style: TextStyle(color: Colors.blue)),
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
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
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
                  MaterialPageRoute(builder: (_) => ProductDescriptionPage(initialDescription: _descripcion)),
                );
                if (result != null) {
                  setState(() => _descripcion = result);
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
                  setState(() => _categoria = result);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_money),
              title: _precio != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PEN ${_precio!.toStringAsFixed(2)}'),
                        if (_precioComparacion != null)
                          Text(
                            'PEN ${_precioComparacion!.toStringAsFixed(2)}',
                            style: const TextStyle(decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    )
                  : const Text('Poner precio'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrecioPage(
                      initialPrecio: _precio?.toString(),
                      initialComparacion: _precioComparacion?.toString(),
                      initialCosto: _costoArticulo?.toString(),
                      initialCobrarImpuestos: _cobrarImpuestos,
                    ),
                  ),
                );
                if (result is Map<String, dynamic>) {
                  setState(() {
                    _precio = double.tryParse(result['precio'] ?? '');
                    _precioComparacion = double.tryParse(result['comparacion'] ?? '');
                    _costoArticulo = double.tryParse(result['costo'] ?? '');
                    _cobrarImpuestos = result['cobrarImpuestos'] ?? true;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Canales de ventas', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Text('Editar', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CanalesVentaPage()));
              },
            ),
            const Text('Tienda online, Point of Sale'),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add),
              title: _opciones.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _opciones.map((opcion) {
                        final nombre = opcion.keys.first;
                        final valores = opcion[nombre]!;
                        return Text('$nombre (${valores.length}) ${valores.join(', ')}');
                      }).toList(),
                    )
                  : const Text('Agregar opciones (color, talla, etc.)'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OpcionesPage(opcionesIniciales: _opciones)),
                );

                if (result is List<Map<String, List<String>>>) {
                  setState(() => _opciones = result);
                }
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add),
              title: const Text('Variantes'),
              subtitle: _variantes.isNotEmpty ? Text('${_variantes.length} variantes configuradas') : null,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VariantesPage(
                      opciones: _opciones,
                      variantesIniciales: _variantes,
                    ),
                  ),
                );

                if (result is List<Map<String, dynamic>>) {
                  setState(() => _variantes = result);
                }
              },
            ),

            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Inventario por variante', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Text('Editar', style: TextStyle(color: Colors.blue)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventarioVariantesPage(variantes: _variantes),
                  ),
                );
                if (result is List<Map<String, dynamic>>) {
                  setState(() => _variantes = result);
                }
              },
            ),

            const Divider(height: 32),
            const ListTile(contentPadding: EdgeInsets.zero, title: Text('Envío')),
            const ListTile(contentPadding: EdgeInsets.zero, title: Text('Tipo')),
            const ListTile(contentPadding: EdgeInsets.zero, title: Text('Proveedor'), subtitle: Text('Mi tienda')),
            const ListTile(contentPadding: EdgeInsets.zero, title: Text('Etiquetas')),
          ],
        ),
      ),
    );
  }
}
