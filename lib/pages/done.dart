import 'package:flutter/material.dart';
import 'package:mobilechallenges/banco/banco.dart';

class Done extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _loadCompletedTasks() async {
    try {
      final db = await Banco().database;
      final completedTasks = await db.query(
        Banco().getTableName(),
        where: 'isChecked = ?',
        whereArgs: [1],
      );
      return completedTasks;
    } catch (e) {
      print("Erro ao carregar tarefas finalizadas: $e");
      return [];
    }
  }

  Future<void> _deleteTask(int taskId) async {
    await Banco().deleteTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadCompletedTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar tarefas finalizadas.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma tarefa finalizada.'));
        }

        final completedTasks = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      task['task'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTask(task['id']);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }
}
