// screens/RegisterScreen.dart
import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/screens/AdminDashboardScreen.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
// import 'package:proyecto_moviles_2/screens/main_screen.dart'; // No se usará directamente para el cliente ahora
import 'package:proyecto_moviles_2/screens/preference_onboarding_screen.dart'; // Importa la pantalla de onboarding

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRol = 'cliente';
  bool _loading = false;

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = AuthService();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _selectedRol,
      _nombreCtrl.text.trim(),
      _telefonoCtrl.text.trim(),
    );

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

      if (_selectedRol == 'vendedor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        // --- CAMBIO CLAVE AQUÍ: YA NO PASAMOS EL CALLBACK ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    const PreferenceOnboardingScreen(), // <<<--- SIN onPreferencesSaved:
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el usuario')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Ingrese su nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                ),
                validator:
                    (v) =>
                        v == null || v.length < 9
                            ? 'Número inválido (mínimo 9 dígitos)'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator:
                    (v) =>
                        v == null || !v.contains('@')
                            ? 'Correo inválido'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator:
                    (v) =>
                        v == null || v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRol,
                decoration: const InputDecoration(labelText: 'Tipo de usuario'),
                items: const [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRol = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _onRegister,
                    child: const Text('Registrarse'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
