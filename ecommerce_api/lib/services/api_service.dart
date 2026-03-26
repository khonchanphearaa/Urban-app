import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class ApiService {
  // Centralized header logic
  static Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Simplified POST helper
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
    final headers = await _getHeaders();
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  // Simplified DELETE helper
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${ApiConstants.apiBaseUrl}$endpoint');
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }

  
}