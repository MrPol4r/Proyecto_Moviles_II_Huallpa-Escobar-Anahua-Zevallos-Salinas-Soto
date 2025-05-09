import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = false;
  String? _selectedRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) _selectedRole = args;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);

    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (success) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'nombre': _nameController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'correo': _emailController.text.trim(),
          'rol': _selectedRole ?? 'cliente',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (_selectedRole == 'vendedor') {
          Navigator.pushReplacementNamed(context, AppRoutes.sellerHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar en Firestore: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al registrarse')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 90,
                  color: Color(0xFFD84315),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Crea tu cuenta en TrendyCart",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _inputField(
                  controller: _nameController,
                  hint: 'Nombre completo',
                  icon: Icons.person,
                  validator: (v) => v!.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),
                _inputField(
                  controller: _phoneController,
                  hint: 'Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 9 ? 'Número no válido' : null,
                ),
                const SizedBox(height: 16),
                _inputField(
                  controller: _emailController,
                  hint: 'Correo electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (v) => v!.isEmpty ? 'Ingrese un correo válido' : null,
                ),
                const SizedBox(height: 16),
                _inputField(
                  controller: _passwordController,
                  hint: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                  validator:
                      (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: false,
                  initialValue:
                      _selectedRole != null
                          ? _selectedRole![0].toUpperCase() +
                              _selectedRole!.substring(1)
                          : 'Cliente',
                  decoration: InputDecoration(
                    hintText: 'Rol seleccionado',
                    prefixIcon: const Icon(Icons.account_circle),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84315),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
