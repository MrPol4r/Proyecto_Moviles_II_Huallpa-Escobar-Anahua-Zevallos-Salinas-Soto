import 'package:flutter/material.dart';

class RegistroCaer extends StatefulWidget {
  @override
  _RegistroCaerState createState() => _RegistroCaerState();
}

class _RegistroCaerState extends State<RegistroCaer> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simulación de correos ya registrados
  final List<String> correosRegistrados = ['test@example.com', 'usuario@correo.com'];

  String _mensaje = '';

  void _registrarUsuario() {
    if (_formKey.currentState!.validate()) {
      final correo = _correoController.text.trim();

      if (correosRegistrados.contains(correo)) {
        setState(() {
          _mensaje = 'Este correo electrónico ya está registrado';
        });
      } else {
        // Simulación de creación de cuenta
        setState(() {
          _mensaje = 'Registro exitoso. Redirigiendo a inicio de sesión...';
        });

        // Aquí se considera hacer un Navigator.pushReplacement a la pantalla de login
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Regresa a la pantalla anterior (login)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final correoRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  } else if (!correoRegExp.hasMatch(value)) {
                    return 'Formato de correo inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarUsuario,
                child: Text('Registrarse'),
              ),
              SizedBox(height: 10),
              if (_mensaje.isNotEmpty)
                Text(
                  _mensaje,
                  style: TextStyle(
                    color: _mensaje.contains('exitoso') ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
