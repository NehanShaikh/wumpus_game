import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  /// Get saved JWT token
  static Future<String?> getToken() async {
    final token = await ApiService.getToken();
    print("AuthService.getToken: $token");
    return token;
  }

  /// Login and save token
  static Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiService.baseUrl}/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("Login status: ${res.statusCode}");
      print("Login response: ${res.body}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['token'] != null) {
          await ApiService.saveToken(body['token']);
          print("Token saved successfully");
          return true;
        } else {
          print("No token in response");
        }
      } else {
        print("Login failed: ${res.body}");
      }
    } catch (e) {
      print("Login error: $e");
    }
    return false;
  }

  /// Register new user
  static Future<bool> register(
      String name, String email, String password) async {
    try {
      final res = await ApiService.post("/auth/register", {
        "name": name,
        "email": email,
        "password": password,
      });

      print("Register status: ${res.statusCode}");
      print("Register response: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("Register error: $e");
      return false;
    }
  }

  /// Logout
  static Future<void> logout() async {
    print("Logging out, clearing token...");
    await ApiService.clearToken();
  }
}
