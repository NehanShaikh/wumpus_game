import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use your current ngrok URL
  static const String baseUrl =
      "https://nacreous-treva-downheartedly.ngrok-free.dev/api";

  static final _storage = FlutterSecureStorage();

  // Get token from secure storage
  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'jwt');
    print("Retrieved token: $token");
    return token;
  }

  static Future<void> saveToken(String token) async {
    print("Saving token: $token");
    await _storage.write(key: 'jwt', value: token);
  }

  static Future<void> clearToken() async {
    print("Clearing token");
    await _storage.delete(key: 'jwt');
  }

  // POST request
  static Future<http.Response> post(
      String path, Map<String, dynamic> data) async {
    final token = await getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
    print("POST $baseUrl$path\nHeaders: $headers\nBody: $data");
    return http.post(Uri.parse("$baseUrl$path"),
        headers: headers, body: jsonEncode(data));
  }

  // GET request
  static Future<http.Response> get(String path) async {
    final token = await getToken();
    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
    print("GET $baseUrl$path\nHeaders: $headers");
    return http.get(Uri.parse("$baseUrl$path"), headers: headers);
  }
}
