import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('usuario').get();

    setState(() {
      usuarios =
          snapshot.docs
              .where((doc) => doc.data()['activo'] != false)
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
    });
  }

  void _mostrarFormulario({Map<String, dynamic>? usuario}) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _FormularioUsuarioDialog(usuario: usuario),
    );

    if (resultado != null) {
      final ref = FirebaseFirestore.instance.collection('usuario');

      if (resultado['id'] == null) {
        await ref.add({...resultado, 'activo': true});
      } else {
        final id = resultado['id'];
        resultado.remove('id');
        await ref.doc(id).update(resultado);
      }

      await _cargarUsuarios();
    }
  }

  void _marcarComoInactivo(String id) async {
    await FirebaseFirestore.instance.collection('usuario').doc(id).update({
      'activo': false,
    });
    await _cargarUsuarios();
  }

  void _confirmarInactivar(String id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Inactivar Usuario'),
            content: const Text(
              '¿Estás seguro de marcar este usuario como inactivo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _marcarComoInactivo(id);
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Agregar usuario',
            onPressed: () => _mostrarFormulario(),
          ),
        ],
      ),
      body:
          usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios activos.'))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: usuarios.length,
                itemBuilder: (_, i) {
                  final u = usuarios[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(u['nombre'] ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${u['usuario']}'),
                          Text('Teléfono: ${u['telefono']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostrarFormulario(usuario: u),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _confirmarInactivar(u['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class _FormularioUsuarioDialog extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const _FormularioUsuarioDialog({this.usuario});

  @override
  State<_FormularioUsuarioDialog> createState() =>
      _FormularioUsuarioDialogState();
}

class _FormularioUsuarioDialogState extends State<_FormularioUsuarioDialog> {
  late TextEditingController nombreController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;
  late TextEditingController contrasenaController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.usuario?['nombre']);
    emailController = TextEditingController(text: widget.usuario?['usuario']);
    telefonoController = TextEditingController(
      text: widget.usuario?['telefono']?.toString(),
    );
    contrasenaController = TextEditingController(
      text: widget.usuario?['contrasena'],
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.usuario == null ? 'Agregar Usuario' : 'Editar Usuario',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final data = {
              'id': widget.usuario?['id'],
              'nombre': nombreController.text.trim(),
              'usuario': emailController.text.trim(),
              'telefono': int.tryParse(telefonoController.text.trim()) ?? 0,
              'contrasena': contrasenaController.text.trim(),
            };
            Navigator.pop(context, data);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
