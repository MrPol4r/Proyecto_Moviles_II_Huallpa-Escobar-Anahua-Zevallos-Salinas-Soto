import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_moviles_2/screens/FullScreenImageScreen.dart';
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
  final FavoriteService _favoriteService = FavoriteService();

  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  // Creamos una copia mutable del producto para poder actualizar la valoración
  // Inicializamos _currentProduct aquí directamente con widget.product
  late Product
  _currentProduct; // Ya no necesitas 'late' aquí si lo inicializas en initState

  bool _isLoadingProductData =
      true; // Nuevo estado para controlar la carga inicial del producto

  // Lista de URLs de imágenes a mostrar en el carrusel, actualizable por color
  List<String> _displayImages = [];

  @override
  void initState() {
    super.initState();
    // Inicializar _currentProduct con el producto original de forma inmediata
    _currentProduct = widget.product;

    isFavorite = false;
    _checkFavoriteStatus();
    _loadProductData(); // Llama a esta función para cargar los datos más recientes del producto

    // Inicializar tallas y colores si solo hay una opción
    if (widget.product.tallas.length == 1) {
      _selectedSize = widget.product.tallas[0];
    }
    if (widget.product.colores.length == 1) {
      _selectedColor = widget.product.colores[0];
    }

    // Inicializar _displayImages y aplicar la lógica de color si aplica
    _updateDisplayImages();
  }

  // Resto de tu código sigue igual...
  // ...

  /// Actualiza la lista de imágenes a mostrar basada en el color seleccionado.
  void _updateDisplayImages() {
    setState(() {
      if (_selectedColor != null &&
          _currentProduct.colorImagenes.containsKey(_selectedColor)) {
        // Si hay una imagen específica para el color, úsala
        _displayImages = [_currentProduct.colorImagenes[_selectedColor]!];
      } else {
        // Si no hay color seleccionado o no hay imagen específica, usa las imágenes generales
        _displayImages = _currentProduct.imagenes;
      }
      // Asegurarse de que haya al menos una imagen si la lista está vacía
      if (_displayImages.isEmpty) {
        _displayImages = [
          'assets/images/placeholder.png',
        ]; // Imagen de respaldo
      }
    });
  }

  void _checkFavoriteStatus() async {
    if (AuthService.isUserLoggedIn()) {
      bool status = await _favoriteService.isFavorite(widget.product.id);
      setState(() {
        isFavorite = status;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _obtenerComentarios() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('producto')
              .doc(widget.product.id)
              .collection('comentarios')
              .orderBy('fecha', descending: true)
              .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener comentarios: $e');
      return [];
    }
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
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };

    final productRef = FirebaseFirestore.instance
        .collection('producto')
        .doc(widget.product.id);

    try {
      await productRef.collection('comentarios').add(comentario);

      final comentariosSnapshot =
          await productRef.collection('comentarios').get();
      double sumaValoraciones = 0;
      int totalComentarios = comentariosSnapshot.docs.length;

      for (var doc in comentariosSnapshot.docs) {
        sumaValoraciones += (doc.data()['valoracion'] as num).toDouble();
      }

      double nuevaValoracionPromedio =
          totalComentarios > 0 ? sumaValoraciones / totalComentarios : 0.0;

      await productRef.update({
        'valoracion': nuevaValoracionPromedio,
        'valoracionesTotal': totalComentarios,
      });

      setState(() {
        _comentarioCtrl.clear();
        _valoracionNueva = 0;
        _currentProduct = _currentProduct.copyWith(
          valoracion: nuevaValoracionPromedio,
          valoracionesTotal: totalComentarios,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado correctamente.')),
      );
    } catch (e) {
      print('Error al agregar comentario o actualizar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar el comentario. Intenta de nuevo.'),
        ),
      );
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar al carrito.'),
        ),
      );
      return;
    }

    final product = _currentProduct;

    if (product.tallas.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una talla.')),
      );
      return;
    }
    if (product.colores.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un color.')),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser al menos 1.')),
      );
      return;
    }

    if (_quantity > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hay suficiente stock disponible. Stock actual: ${product.stock}',
          ),
        ),
      );
      return;
    }

    String cartItemId = product.id;
    if (_selectedSize != null) cartItemId += '-$_selectedSize';
    if (_selectedColor != null) cartItemId += '-$_selectedColor';

    final cartItemRef = FirebaseFirestore.instance
        .collection('carrito')
        .doc(user.uid)
        .collection('items')
        .doc(cartItemId);

    try {
      final docSnapshot = await cartItemRef.get();

      if (docSnapshot.exists) {
        await cartItemRef.update({'cantidad': FieldValue.increment(_quantity)});
      } else {
        await cartItemRef.set({
          'nombre': product.nombre,
          'precio': product.precio,
          'imagen': _displayImages.isNotEmpty ? _displayImages[0] : '',
          'cantidad': _quantity,
          'descuento': product.descuento,
          'id_producto': product.id,
          'id_vendedor': product.idVendedor,
          'talla': _selectedSize,
          'color': _selectedColor,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Agregado al carrito: "${product.nombre}" (x$_quantity)',
          ),
        ),
      );
      setState(() {
        _quantity = 1;
      });
    } catch (e) {
      print('Error al agregar al carrito: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error al agregar el producto al carrito. Intenta de nuevo.',
          ),
        ),
      );
    }
  }

  // Nuevo método para cargar los datos más recientes del producto
  Future<void> _loadProductData() async {
    setState(() {
      _isLoadingProductData = true; // Indicar que estamos cargando
    });
    try {
      final productDoc =
          await FirebaseFirestore.instance
              .collection('producto')
              .doc(widget.product.id)
              .get();

      if (productDoc.exists) {
        // Actualizar _currentProduct con los datos más recientes de Firestore
        setState(() {
          _currentProduct = Product.fromFirestore(productDoc);
        });
      } else {
        // Si el documento no existe (raro si ya tenemos el producto), mantener el original
        setState(() {
          _currentProduct = widget.product;
        });
      }
    } catch (e) {
      print('Error al cargar los datos del producto: $e');
      // En caso de error, volvemos a usar el producto inicial
      setState(() {
        _currentProduct = widget.product;
      });
    } finally {
      setState(() {
        _isLoadingProductData = false; // Finalizar la carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si los datos del producto aún están cargando, muestra un CircularProgressIndicator
    if (_isLoadingProductData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Producto...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final product = _currentProduct;
    final precioConDescuento = product.precio * (1 - product.descuento / 100);

    final bool canAddToCart =
        product.stock > 0 &&
        (product.tallas.isEmpty || _selectedSize != null) &&
        (product.colores.isEmpty || _selectedColor != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              if (!AuthService.isUserLoggedIn()) {
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
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: _displayImages.length,
                itemBuilder: (context, index) {
                  final imageUrl = _displayImages[index];
                  return GestureDetector(
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

            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(product.descripcion),
            const Divider(height: 32),

            if (product.colores.isNotEmpty) ...[
              const Text(
                'Selecciona un Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    product.colores.map((color) {
                      return ChoiceChip(
                        label: Text(color),
                        selected: _selectedColor == color,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedColor = selected ? color : null;
                            _updateDisplayImages();
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color:
                              _selectedColor == color
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            if (product.tallas.isNotEmpty) ...[
              const Text(
                'Selecciona una Talla',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    product.tallas.map((talla) {
                      return ChoiceChip(
                        label: Text(talla),
                        selected: _selectedSize == talla,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedSize = selected ? talla : null;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color:
                              _selectedSize == talla
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 6),
              Text(
                product.descripcionTallas,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Cantidad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text(
                  _quantity.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            Text(
              'Stock disponible: ${product.stock}',
              style: TextStyle(
                fontSize: 14,
                color: product.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.stock == 0)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  '¡Producto agotado!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Divider(height: 32),

            const Text(
              'Comentarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            FutureBuilder<Map<String, dynamic>?>(
              future: AuthService.getUserData(),
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
                    'Debes iniciar sesión para comentar.',
                    style: TextStyle(color: Colors.grey),
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
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar comentarios: ${snapshot.error}',
                    ),
                  );
                }
                final comentarios = snapshot.data ?? [];
                if (comentarios.isEmpty) {
                  return const Text(
                    'Aún no hay comentarios. ¡Sé el primero en dejar uno!',
                    style: TextStyle(color: Colors.grey),
                  );
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

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAddToCart ? _addToCart : null,
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: Text(
                  product.stock > 0 ? 'Agregar al Carrito' : 'Producto Agotado',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAddToCart ? Colors.blue : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
