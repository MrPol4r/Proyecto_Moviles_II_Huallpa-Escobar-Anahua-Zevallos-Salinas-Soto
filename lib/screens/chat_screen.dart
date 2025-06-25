import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth para obtener el usuario actual
import '../models/product.dart';
import 'package:proyecto_moviles_2/screens/product_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  Map<String, dynamic>?
  _userPreferences; // Variable para almacenar las preferencias del usuario

  @override
  void initState() {
    super.initState();
    _loadUserPreferences(); // Cargar las preferencias al iniciar la pantalla
    _sendInitialGreeting(); // Envía un mensaje inicial de bienvenida
  }

  // Método para cargar las preferencias del usuario desde Firestore
  Future<void> _loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('usuario')
                .doc(user.uid)
                .get();
        if (userDoc.exists) {
          setState(() {
            _userPreferences = userDoc.data();
          });
          print('Preferencias del usuario cargadas: $_userPreferences');
        }
      } catch (e) {
        print('Error al cargar las preferencias del usuario: $e');
      }
    }
  }

  // Mensaje de bienvenida con o sin preferencias
  void _sendInitialGreeting() async {
    String greeting =
        "¡Hola! Soy tu asistente de moda. ¿En qué puedo ayudarte hoy?";

    // Esperar a que las preferencias se carguen
    // Una pequeña demora para asegurar que _userPreferences tenga un valor después de _loadUserPreferences
    await Future.delayed(const Duration(milliseconds: 500));

    if (_userPreferences != null && _userPreferences!.isNotEmpty) {
      final colores =
          _userPreferences!['colores_preferidos']?.join(', ') ?? 'ninguno';
      final estilo = _userPreferences!['estilo_preferido'] ?? 'ninguno';
      final genero = _userPreferences!['genero'] ?? 'ninguno';
      final tipoPrenda =
          _userPreferences!['tipo_prenda_favorita']?.join(', ') ?? 'ninguna';

      greeting += "\nVeo que tienes algunas preferencias: ";
      if (colores != 'ninguno') greeting += "Colores: $colores. ";
      if (estilo != 'ninguno') greeting += "Estilo: $estilo. ";
      if (genero != 'ninguno') greeting += "Género: $genero. ";
      if (tipoPrenda != 'ninguna')
        greeting += "Tipo de prenda favorita: $tipoPrenda. ";
      greeting += "\n¿Hay algo en particular que estés buscando hoy?";
    } else {
      greeting +=
          "\nNo he encontrado preferencias registradas. Dime, ¿qué tipo de ropa te gusta?";
    }

    setState(() {
      _messages.insert(0, {'sender': 'gemini', 'text': greeting});
    });
  }

  Future<List<Product>> _obtenerProductos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('producto').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  String _generarResumenProductos(List<Product> productos) {
    return productos
        .take(
          10,
        ) // Limita a los primeros 10 productos para no exceder el límite de tokens
        .map((p) {
          return "ID: ${p.id}, producto: ${p.nombre}, categoria: ${p.categoria}, precio: ${p.precio} soles, descuento: ${p.descuento}%, tallas: ${p.tallas.join(', ')}, colores: ${p.colores.join(', ')}, stock: ${p.stock}";
        })
        .join("\n");
  }

  Future<String> _getGeminiResponse(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } catch (_) {
        return "❌ No se pudo obtener respuesta.";
      }
    } else {
      print("Error Gemini: ${response.statusCode} → ${response.body}");
      return "❌ Error al contactar a Gemini.";
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, {'sender': 'user', 'text': text});
      _controller.clear();
    });

    final productos = await _obtenerProductos();
    final resumenProductos = _generarResumenProductos(productos);

    // Construir el prompt con las preferencias del usuario si están disponibles
    String preferenciasPrompt = "";
    if (_userPreferences != null && _userPreferences!.isNotEmpty) {
      final colores =
          _userPreferences!['colores_preferidos']?.join(', ') ?? 'ninguno';
      final estilo = _userPreferences!['estilo_preferido'] ?? 'ninguno';
      final genero = _userPreferences!['genero'] ?? 'ninguno';
      final tipoPrenda =
          _userPreferences!['tipo_prenda_favorita']?.join(', ') ?? 'ninguna';

      preferenciasPrompt = """
      Las preferencias conocidas del usuario son:
      Colores preferidos: $colores
      Estilo preferido: $estilo
      Género: $genero
      Tipo de prenda favorita: $tipoPrenda
      """;
    }

    final mensajeCompleto = """
    Eres un asistente de moda amable y útil, especializado en recomendar productos de ropa. Tu objetivo es ayudar al usuario a encontrar prendas que le gusten.
    Si el usuario pregunta por recomendaciones, usa sus preferencias (si las conoces) y la lista de productos disponibles.
    Siempre menciona el nombre del producto exacto al hacer una recomendación.
    Si el usuario pregunta algo que no tenga que ver con productos o ropa, responde amablemente que tu función es recomendar ropa.
    Si un producto tiene stock 0, no lo recomiendes.
    Si los productos que recomiendas tienen la talla o el color que el usuario busca, menciónalo también.
    
    Usuario: $text
    
    $preferenciasPrompt
    
    Aquí tienes la información detallada de los productos disponibles en nuestra tienda:
    $resumenProductos
    
    Basándote en la pregunta del usuario y sus preferencias (si las conoces) y la lista de productos disponibles, ¿qué producto de ropa recomiendas? Por favor, sé conciso y directo con la recomendación. Si hay más de una, puedes mencionar hasta 3 productos. Si mencionas un producto, indica su nombre completo y si tiene descuento.
    """;

    final respuesta = await _getGeminiResponse(mensajeCompleto);

    // Extraer los IDs de productos de la respuesta de Gemini (si los hay)
    // Se buscarán los nombres de productos y luego se mapearán a IDs para la navegación
    final List<Product> recomendados = [];
    for (var product in productos) {
      // Usar una expresión regular para una búsqueda más flexible (palabra completa)
      final regex = RegExp(
        r'\b' + RegExp.escape(product.nombre.toLowerCase()) + r'\b',
      );
      if (respuesta.toLowerCase().contains(regex)) {
        recomendados.add(product);
      }
    }

    setState(() {
      _messages.insert(0, {
        'sender': 'gemini',
        'text': respuesta,
        'productos': recomendados, // Pasa los objetos Product completos
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Ropa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final productos = await _obtenerProductos();
              final resumen = _generarResumenProductos(productos);
              print("📦 Producto:\n$resumen");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final sender = message['sender'];
                final text = message['text'] ?? '';
                final productosRecomendados =
                    message['productos'] as List<Product>?;

                return Column(
                  crossAxisAlignment:
                      sender == 'user'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              sender == 'user'
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(text),
                      ),
                    ),
                    if (productosRecomendados != null &&
                        productosRecomendados.isNotEmpty)
                      ...productosRecomendados
                          .map(
                            (product) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  leading:
                                      product.imagenes.isNotEmpty
                                          ? Image.network(
                                            product.imagenes[0],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Image.asset(
                                                  'assets/images/placeholder.png',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                          )
                                          : Image.asset(
                                            'assets/images/placeholder.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                  title: Text(product.nombre),
                                  subtitle: Text(
                                    'S/ ${product.precio.toStringAsFixed(2)} ' +
                                        (product.descuento > 0
                                            ? '(Descuento: ${product.descuento}%)'
                                            : ''),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (ctx) => ProductDetailScreen(
                                              product: product,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
