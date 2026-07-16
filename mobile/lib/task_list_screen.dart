import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _api = ApiService();
  List<dynamic> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final tasks = await _api.getTasks();
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _toggle(Map task) async {
    await _api.updateTask(task['id'] as int,
        completed: !(task['completed'] as bool));
    _load();
  }

  Future<void> _delete(Map task) async {
    await _api.deleteTask(task['id'] as int);
    _load();
  }

  Future<void> _addDialog() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Task nou'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Adaugă'),
          ),
        ],
      ),
    );
    if (title != null && title.trim().isNotEmpty) {
      await _api.createTask(title.trim());
      _load();
    }
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task-urile mele'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _tasks.isEmpty
                  ? const Center(child: Text('Niciun task încă.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, i) {
                        final task = _tasks[i] as Map;
                        return Dismissible(
                          key: ValueKey(task['id']),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _delete(task),
                          background: Container(color: Colors.red),
                          child: CheckboxListTile(
                            value: task['completed'] as bool,
                            onChanged: (_) => _toggle(task),
                            title: Text(task['title'] as String),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
