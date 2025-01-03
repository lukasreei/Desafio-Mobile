import 'package:flutter/material.dart';
import 'package:mobilechallenges/banco/banco.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final db = await Banco().database;
      final tasks = await db.query(Banco().getTableName());
      setState(() {
        _tasks = tasks;
        _filteredTasks = tasks;
      });
    } catch (e) {
      print("Erro ao carregar tarefas: $e");
    }
  }

  void _filterTasks(String query) {
    final filtered = _tasks.where((task) {
      final taskName = task['task'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return taskName.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredTasks = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterTasks,
            decoration: const InputDecoration(
              labelText: 'Pesquisar Tarefa',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(child: Text('Nenhuma tarefa encontrada.'))
                : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                final isChecked = task['isChecked'] == 1;
                return Container(
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
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ),
    );
  }
}
