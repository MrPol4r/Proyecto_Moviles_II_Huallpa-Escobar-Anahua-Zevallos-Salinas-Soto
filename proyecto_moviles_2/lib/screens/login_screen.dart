// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'user@correo.com');
  final _passCtrl  = TextEditingController(text: 'password123');
  bool _loading = false;

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final ok = await AuthService.signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (ok) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        throw 'Credenciales incorrectas';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.isEmpty)     return 'Ingresa tu email';
                  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) 
                                                   return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _onLogin,
                    child: const Text('Ingresar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
