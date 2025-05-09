import 'package:flutter/material.dart';

class CategoriaPage extends StatelessWidget {
  const CategoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categorias = [
      'Productos para mascotas y animales',
      'Ropa y accesorios',
      'Arte y ocio',
      'Bebés y niños pequeños',
      'Economía e industria',
      'Cámaras y ópticas',
      'Electrónica',
      'Alimentación, bebida y tabaco',
      'Mobiliario',
      'Salud y belleza',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Todas las categorías'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar categorías',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: categorias.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categorias[index]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Aquí podrías usar Navigator.pop para devolver la categoría seleccionada
                    Navigator.pop(context, categorias[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
