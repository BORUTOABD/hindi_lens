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
  static const String baseUrl = 'http://13.71.6.245:8000';

  // 1. Direct English Text -> Hindi Translation
  // Handles JSON body, query params, and form-data to prevent 422 errors
  static Future<TranslationResult> translateText({
    required String text,
    String direction = 'en-hi',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/translate-text-en-hi');

      // Attempt 1: Standard JSON body
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 25));

      // Attempt 2: If FastAPI expects query parameters
      if (response.statusCode == 422) {
        final queryUri = Uri.parse('$baseUrl/translate-text-en-hi?text=${Uri.encodeComponent(text)}');
        response = await http.post(
          queryUri,
          headers: {'accept': 'application/json'},
        ).timeout(const Duration(seconds: 25));
      }

      // Attempt 3: If FastAPI expects form-url-encoded
      if (response.statusCode == 422) {
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'text': text},
        ).timeout(const Duration(seconds: 25));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TranslationResult(
          hindiText: data['translated_text'] ?? data['hindi_text'] ?? '',
          englishText: text,
        );
      } else {
        return TranslationResult(
          hindiText: '',
          englishText: '',
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TranslationResult(
        hindiText: '',
        englishText: '',
        error: 'Translation failure: $e',
      );
    }
  }

  // 2. Image OCR + Translation (Routes based on direction)
  static Future<TranslationResult> translateImage(
    File imageFile, {
    String direction = 'hi-en',
  }) async {
    try {
      final endpoint = direction == 'en-hi' ? '/translate-en-hi' : '/translate';
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TranslationResult(
          hindiText: data['hindi_text'] ?? '',
          englishText: data['english_text'] ?? '',
        );
      } else {
        final data = jsonDecode(response.body);
        return TranslationResult(
          hindiText: '',
          englishText: '',
          error: data['detail'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TranslationResult(
        hindiText: '',
        englishText: '',
        error: 'Translation failure: $e',
      );
    }
  }
}