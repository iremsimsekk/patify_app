import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<String> askQuestion(String question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/ask'),
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
