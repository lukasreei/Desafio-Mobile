import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobilechallenges/pages/create.dart';
import 'package:mobilechallenges/pages/done.dart';
import 'package:mobilechallenges/pages/search.dart';
import 'package:mobilechallenges/banco/banco.dart';

class Todo extends StatefulWidget {
  Todo({Key? key}) : super(key: key);

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return Task();
      case 1:
        return Create(onAddTask: _addTask);
      case 2:
        return Search();
      case 3:
        return Done();
      default:
        return Task();
    }
  }

  Future<List<Map<String, dynamic>>> _loadTasks() async {
    try {
      final db = await Banco().database;
      final tasks = await db.query(
        Banco().getTableName(),
        where: 'isChecked = ?',
        whereArgs: [0],
      );
      return tasks;
    } catch (e) {
      print("Erro ao carregar tarefas: $e");
      return [];
    }
  }

  Future<void> _addTask(String task) async {
    await Banco().insertTask(task, false);
    setState(() {});
  }

  Future<void> _updateTask(int taskId, bool isChecked) async {
    await Banco().updateTask(taskId, isChecked);
    setState(() {});
  }

  Future<void> _deleteTask(int taskId) async {
    await Banco().deleteTask(taskId);
    setState(() {});
  }

  Widget Task() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar tarefas.'));
        }

        final tasks = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome, ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'John',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              tasks.isEmpty
                  ? const Text(
                'Você não tem tarefas no momento.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              )
                  : Text(
                'Você tem ${tasks.length} tarefas a fazer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Exibir a lista de tarefas
              if (tasks.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isChecked = task['isChecked'] == 1;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Create(
                                onAddTask: _addTask,
                                task: task,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  _updateTask(task['id'], value!);
                                },
                                activeColor: Colors.blueAccent,
                              ),
                              SizedBox(width: 12),
                              Text(
                                task['task'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
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
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Taski', style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 22,
          ),),
        ),
        centerTitle: false,
        backgroundColor: Colors.blueAccent,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'John',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _getSelectedPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Done',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
