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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _api.getTasks();
      if (!mounted) return;
      setState(() => _tasks = tasks);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Nu am putut încărca task-urile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  Widget _buildBody() {
    if (_error != null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ],
      );
    }
    if (_tasks.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Niciun task încă.')),
          ),
        ],
      );
    }
    return ListView.builder(
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
          : RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }
}
