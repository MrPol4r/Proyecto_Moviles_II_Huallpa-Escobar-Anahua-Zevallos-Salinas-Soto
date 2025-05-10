import 'package:flutter/material.dart';

void main() => runApp(ProductQuestionsApp());

class ProductQuestionsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dudas de Productos',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: ProductQuestionPage(),
    );
  }
}

class ProductQuestionPage extends StatefulWidget {
  @override
  _ProductQuestionPageState createState() => _ProductQuestionPageState();
}

class _ProductQuestionPageState extends State<ProductQuestionPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _questions = [];

  void _submitQuestion() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _questions.insert(0, _controller.text.trim());
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dudas de Productos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Escribe tu duda...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitQuestion,
              child: Text('Enviar'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _questions.isEmpty
                  ? Center(child: Text('No hay dudas aún.'))
                  : ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(Icons.question_answer),
                            title: Text(_questions[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
