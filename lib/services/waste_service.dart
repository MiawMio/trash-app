import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trash_app/services/auth_service.dart';

class WasteService {
  final String _baseUrl = 'https://trash-api-azure.vercel.app/api';

  Future<void> submitWaste({
    required String categoryId,
    required double weightInGrams,
  }) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final url = Uri.parse('$_baseUrl/submissions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'categoryId': categoryId,
        'weightInGrams': weightInGrams,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit waste. Error: ${response.body}');
    }
  }
}