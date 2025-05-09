import 'package:flutter/material.dart';

class HomeClientScreen extends StatelessWidget {
  const HomeClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Cliente'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          'Bienvenido, Cliente 👤',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
