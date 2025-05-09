import 'package:flutter/material.dart';

class ProductDescriptionPage extends StatefulWidget {
  final String? initialDescription;

  const ProductDescriptionPage({super.key, this.initialDescription});

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Descripción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, descriptionController.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: descriptionController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText: 'Escribe la descripción del producto...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
