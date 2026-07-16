import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiService {
  // Schimbă în funcție de unde rulează backendul:
  //  - emulator Android: http://10.0.2.2:8000/api
  //  - simulator iOS:    http://127.0.0.1:8000/api
  //  - telefon fizic:    http://<IP-ul-tău-din-LAN>:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    return _handleAuth(res);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );
    return _handleAuth(res);
  }

  Future<Map<String, dynamic>> _handleAuth(http.Response res) async {
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 || res.statusCode == 201) {
      await TokenStorage.save(data['token'] as String);
      return data;
    }
    throw Exception(data['message'] ?? 'Autentificare eșuată');
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.get();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getTasks() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: await _authHeaders(),
    );
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<void> createTask(String title) async {
    await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: await _authHeaders(),
      body: {'title': title},
    );
  }

  Future<void> updateTask(int id, {String? title, bool? completed}) async {
    await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _authHeaders(),
      body: {
        if (title != null) 'title': title,
        if (completed != null) 'completed': completed ? '1' : '0',
      },
    );
  }

  Future<void> deleteTask(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _authHeaders(),
    );
  }

  Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _authHeaders(),
    );
    await TokenStorage.clear();
  }
}
