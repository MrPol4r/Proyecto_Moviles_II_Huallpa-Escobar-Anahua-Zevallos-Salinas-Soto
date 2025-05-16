import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
//
import 'main_screen.dart';

class PreferencesFormScreen extends StatefulWidget {
  const PreferencesFormScreen({super.key});

  @override
  State<PreferencesFormScreen> createState() => _PreferencesFormScreenState();
}

class _PreferencesFormScreenState extends State<PreferencesFormScreen> {
  String? categoriaSeleccionada;
  String? frecuenciaSeleccionada;
  String? edadSeleccionada;

  final _categorias = ['Electrónica', 'Ropa', 'Libros', 'Hogar'];
  final _frecuencias = ['Diariamente', 'Semanalmente', 'Mensualmente'];
  final _rangosEdad = ['18-25', '26-35', '36-50', '50+'];

  bool _enviando = false;

  Future<void> _guardarPreferencias() async {
    if (categoriaSeleccionada == null ||
        frecuenciaSeleccionada == null ||
        edadSeleccionada == null)
      return;

    setState(() => _enviando = true);

    final userId = AuthService.userId;
    final ref = FirebaseFirestore.instance.collection('usuario').doc(userId);

    await ref.update({
      'preferencias': {
        'categoria': categoriaSeleccionada,
        'frecuencia': frecuenciaSeleccionada,
        'edad': edadSeleccionada,
      },
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias de Recomendación')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Qué tipo de productos prefieres?',
              ),
              items:
                  _categorias
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (v) => setState(() => categoriaSeleccionada = v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Con qué frecuencia compras en línea?',
              ),
              items:
                  _frecuencias
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (v) => setState(() => frecuenciaSeleccionada = v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Cuál es tu rango de edad?',
              ),
              items:
                  _rangosEdad
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (v) => setState(() => edadSeleccionada = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviando ? null : _guardarPreferencias,
              child: const Text('Guardar preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
