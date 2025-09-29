import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  /// Get saved JWT token
  static Future<String?> getToken() async {
    return await ApiService.getToken();
  }

  /// Login and save token (debug version)
  static Future<bool> login(String email, String password) async {
    // Temporary debug HTTP request
    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("Login status: ${res.statusCode}");
    print("Login body: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      await ApiService.saveToken(body['token']);
      return true;
    }

    return false;
  }

  /// Register new user
  static Future<bool> register(
      String name, String email, String password) async {
    final res = await ApiService.post("/auth/register", {
      "name": name,
      "email": email,
      "password": password,
    });
    return res.statusCode == 200;
  }

  /// Logout
  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
