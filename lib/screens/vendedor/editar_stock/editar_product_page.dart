import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/Cloudinary_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/canales_venta_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/categoria_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/descripcion_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/opciones_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/precio_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variant_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/variantes_page.dart';
import 'package:tienda_ropas/screens/vendedor/agregarproductos/inventario_Variantes_Page.dart';
import 'package:tienda_ropas/screens/vendedor/services/product_service.dart';

class EditarProductPage extends StatefulWidget {
  final Map<String, dynamic> producto;

  const EditarProductPage({super.key, required this.producto});

  @override
  State<EditarProductPage> createState() => _EditarProductPageState();
}

class _EditarProductPageState extends State<EditarProductPage> {
  late TextEditingController _nombreController;
  String? _descripcion;
  String? _categoria;
  String? _imageUrl;
  double? _precio;
  double? _precioComparacion;
  double? _costoArticulo;
  bool _cobrarImpuestos = true;
  List<Map<String, List<String>>> _opciones = [];
  List<Map<String, dynamic>> _variantes = [];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreController = TextEditingController(text: p['nombre'] ?? '');
    _descripcion = p['descripcion'];
    _categoria = p['categoria'];
    _imageUrl = p['imagen'];
    _precio = (p['precio'] as num?)?.toDouble();
    _precioComparacion = (p['precio_comparacion'] as num?)?.toDouble();
    _costoArticulo = (p['costo_articulo'] as num?)?.toDouble();
    _cobrarImpuestos = p['cobrar_impuestos'] ?? true;
    _variantes = List<Map<String, dynamic>>.from(p['variantes'] ?? []);
    _opciones = List<Map<String, List<String>>>.from(p['opciones'] ?? []);
  }

  Future<void> _actualizarImagen() async {
    final cloudinary = CloudinaryService();
    final image = await cloudinary.seleccionarImagen();
    if (image != null) {
      final url = await cloudinary.subirImagen(image);
      if (url != null) {
        setState(() => _imageUrl = url);
      }
    }
  }

  Future<void> _guardarCambios() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty || _descripcion == null || _categoria == null || _imageUrl == null || _precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios.')),
      );
      return;
    }

    final productoActualizado = {
      'nombre': nombre,
      'descripcion': _descripcion,
      'categoria': _categoria,
      'imagen': _imageUrl,
      'precio': _precio,
      'precio_comparacion': _precioComparacion,
      'costo_articulo': _costoArticulo,
      'cobrar_impuestos': _cobrarImpuestos,
      'variantes': _variantes,
      'opciones': _opciones,
    };

    await ProductService().actualizarProducto(widget.producto['id'].toString(), productoActualizado);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Editar producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _guardarCambios,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _actualizarImagen,
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
                      : const Icon(Icons.image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            ListTile(
              title: Text(_descripcion ?? 'Agregar descripción'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDescriptionPage(initialDescription: _descripcion),
                  ),
                );
                if (result != null) setState(() => _descripcion = result);
              },
            ),
            ListTile(
              title: Text(_categoria ?? 'Seleccionar categoría'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriaPage()),
                );
                if (result != null) setState(() => _categoria = result);
              },
            ),
            ListTile(
              title: Text(_precio != null ? 'S/ ${_precio!.toStringAsFixed(2)}' : 'Poner precio'),
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
            ListTile(
              title: const Text('Canales de ventas'),
              subtitle: const Text('Tienda online, Point of Sale'),
              trailing: const Text('Editar', style: TextStyle(color: Colors.blue)),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CanalesVentaPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Agregar opciones (color, talla, etc.)'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OpcionesPage(opcionesIniciales: _opciones),
                  ),
                );
                if (result is List<Map<String, List<String>>>) {
                  setState(() => _opciones = result);
                }
              },
            ),
            ListTile(
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
                if (result is List<Map<String, dynamic>>) setState(() => _variantes = result);
              },
            ),
            ListTile(
              title: const Text('Inventario por variante'),
              trailing: const Text('Editar', style: TextStyle(color: Colors.blue)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventarioVariantesPage(variantes: _variantes),
                  ),
                );
                if (result is List<Map<String, dynamic>>) setState(() => _variantes = result);
              },
            ),
          ],
        ),
      ),
    );
  }
}
