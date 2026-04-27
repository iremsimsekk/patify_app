import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AiService {
  Future<String> askQuestion(String question) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/ai/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'] ?? 'Cevap alınamadı.';
    } else {
      throw Exception('AI cevabı alınamadı');
    }
  }
}
