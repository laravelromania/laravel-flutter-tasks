import 'package:flutter/material.dart';
import 'token_storage.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

void main() => runApp(const TasksApp());

class TasksApp extends StatelessWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task-uri',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: FutureBuilder<String?>(
        future: TokenStorage.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == null
              ? const LoginScreen()
              : const TaskListScreen();
        },
      ),
    );
  }
}
