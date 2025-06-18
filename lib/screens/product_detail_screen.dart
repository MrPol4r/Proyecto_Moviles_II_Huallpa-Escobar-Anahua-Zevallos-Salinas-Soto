import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/screens/FullScreenImageScreen.dart';
import 'package:proyecto_moviles_2/screens/favorites_screen.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:proyecto_moviles_2/services/FavoriteService.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool isFavorite;
  final _comentarioCtrl = TextEditingController();
  int _valoracionNueva = 0;
  final FavoriteService _favoriteService =
      FavoriteService(); // Esta instancia sigue siendo necesaria para FavoriteService

  @override
  void initState() {
    super.initState();
    isFavorite = false;
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    // Usa el método estático isUserLoggedIn()
    if (AuthService.isUserLoggedIn()) {
      bool status = await _favoriteService.isFavorite(widget.product.id);
      setState(() {
        isFavorite = status;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _obtenerComentarios() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('producto')
            .doc(widget.product.id)
            .collection('comentarios')
            .orderBy('fecha', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _agregarComentario(String nombreUsuario) async {
    if (_comentarioCtrl.text.trim().isEmpty || _valoracionNueva == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario y da una valoración.'),
        ),
      );
      return;
    }

    print('DEBUG: Valor de nombreUsuario antes de enviar: $nombreUsuario');

    final comentario = {
      'usuario': nombreUsuario,
      'comentario': _comentarioCtrl.text.trim(),
      'valoracion': _valoracionNueva,
      'fecha': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('producto')
        .doc(widget.product.id)
        .collection('comentarios')
        .add(comentario);

    _comentarioCtrl.clear();
    _valoracionNueva = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario agregado correctamente.')),
    );

    setState(() {});
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final precioConDescuento = product.precio * (1 - product.descuento / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        actions: [
          // Botón de favoritos
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              // Usa el método estático isUserLoggedIn()
              if (!AuthService.isUserLoggedIn()) {
                // Si el usuario NO está logueado
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Debes iniciar sesión para añadir a favoritos.',
                    ),
                  ),
                );
                return;
              }

              if (isFavorite) {
                await _favoriteService.removeFavorite(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removido de favoritos.')),
                );
              } else {
                await _favoriteService.addFavorite(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Agregado a favoritos.')),
                );
              }
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: product.imagenes.length,
                itemBuilder: (context, index) {
                  final imageUrl = product.imagenes[index];
                  return GestureDetector(
                    // Envuelve la imagen con GestureDetector
                    onTap: () => _showFullScreenImage(context, imageUrl),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder:
                          (context, error, stackTrace) => Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'S/ ${precioConDescuento.toStringAsFixed(2)} (Antes: S/ ${product.precio.toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < product.valoracion.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 6),
                Text('(${product.valoracionesTotal} valoraciones)'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${product.vendidos} vendidos',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(product.descripcion),
            const Divider(height: 32),

            // Colores disponibles
            const Text(
              'Colores disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  product.colores
                      .map((color) => Chip(label: Text(color)))
                      .toList(),
            ),

            const Divider(height: 32),
            const Text(
              'Tallas disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  product.tallas
                      .map((talla) => Chip(label: Text(talla)))
                      .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              product.descripcionTallas,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 32),

            const Text(
              'Comentarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            FutureBuilder<Map<String, dynamic>?>(
              future:
                  AuthService.getUserData(), // Aquí ya lo usas estático, ¡excelente!
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Error al cargar datos del usuario: ${snapshot.error}',
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data?['nombre'] == null) {
                  return const Text(
                    'Debes iniciar sesión para comentar. Nombre no disponible.',
                  );
                }

                final String nombreUsuario =
                    snapshot.data!['nombre'] ?? 'Usuario';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu valoración:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => IconButton(
                          icon: Icon(
                            i < _valoracionNueva
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _valoracionNueva = i + 1;
                            });
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: _comentarioCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu comentario...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _agregarComentario(nombreUsuario),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                        child: const Text(
                          'Enviar comentario',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _obtenerComentarios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comentarios = snapshot.data ?? [];
                if (comentarios.isEmpty) {
                  return const Text('Aún no hay comentarios.');
                }
                return Column(
                  children:
                      comentarios.map((comentario) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < (comentario['valoracion'] ?? 0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    comentario['usuario'] ?? 'Anónimo',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comentario['comentario'] ?? ''),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
