import 'package:flutter/material.dart';

class Create extends StatefulWidget {
  final Function(String) onAddTask;
  final Map<String, dynamic>? task;

  Create({required this.onAddTask, this.task});

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {
  final _taskController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _taskController.text = widget.task!['task'];
      _descricaoController.text = widget.task!['descricao'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.task == null ? Text('Adicionar Tarefa') : Text('Detalhes da Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Digite a tarefa',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  widget.onAddTask(_taskController.text);
                  _taskController.clear();
                  _descricaoController.clear();
                }
              },
              child: Text(widget.task == null ? 'Adicionar Tarefa' : 'Atualizar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
