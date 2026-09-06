import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranslationResult {
  final String hindiText;
  final String englishText;
  final String? error;

  TranslationResult({
    required this.hindiText,
    required this.englishText,
    this.error,
  });
}

class ApiService {
  // Update this URL with Person B's cloud IP or domain once deployed.
  // 10.0.2.2 points to localhost when running on an Android emulator.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<TranslationResult> translateImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/translate');
      final request = http.MultipartRequest('POST', uri);

      // Multipart field name 'file' required by backend contract
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 25),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TranslationResult(
          hindiText: data['hindi_text'] ?? '',
          englishText: data['english_text'] ?? '',
          error: data['error'],
        );
      } else {
        return TranslationResult(
          hindiText: '',
          englishText: '',
          error: 'Server returned error status: ${response.statusCode}',
        );
      }
    } on SocketException {
      return TranslationResult(
        hindiText: '',
        englishText: '',
        error:
            'Unable to connect to the translation server. Please check your internet connection and try again.',
      );
    } catch (e) {
      return TranslationResult(
        hindiText: '',
        englishText: '',
        error: 'Translation failure: $e',
      );
    }
  }
}