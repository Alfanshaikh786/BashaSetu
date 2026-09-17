import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configurable Backend API Client for Bhasha Setu
/// Enforces Local-First architecture — Never blocks if offline or unreachable
class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  // Environment Defaults
  static const String defaultEmulatorUrl = 'http://10.0.2.2:5000/api';
  static const String defaultPhysicalLanUrl = 'http://192.168.1.100:5000/api';
  static const String defaultLocalhostUrl = 'http://127.0.0.1:5000/api';

  String _baseUrl = defaultEmulatorUrl;
  bool _isBackendEnabled = true;

  String get baseUrl => _baseUrl;
  bool get isBackendEnabled => _isBackendEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? defaultEmulatorUrl;
    _isBackendEnabled = prefs.getBool('api_backend_enabled') ?? true;
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _baseUrl);
  }

  Future<void> setBackendEnabled(bool enabled) async {
    _isBackendEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('api_backend_enabled', _isBackendEnabled);
  }

  /// System health telemetry check (with 1.2s short timeout)
  Future<bool> checkHealth() async {
    if (!_isBackendEnabled) return false;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(milliseconds: 1200));
      return response.statusCode == 200;
    } catch (_) {
      return false; // Silent offline fallback
    }
  }

  /// Optional backend translation query
  Future<Map<String, dynamic>?> queryBackendTranslate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (!_isBackendEnabled) return null;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'source_lang': sourceLang,
              'target_lang': targetLang,
            }),
          )
          .timeout(const Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null; // Transparent local SQLite fallback
    }
  }

  /// Submit community linguistic feedback
  Future<bool> submitFeedback({
    required String sourceText,
    required String targetText,
    required String sourceLang,
    required String targetLang,
    required int rating,
    String? suggestion,
  }) async {
    if (!_isBackendEnabled) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'source_text': sourceText,
              'target_text': targetText,
              'source_lang': sourceLang,
              'target_lang': targetLang,
              'rating': rating,
              'suggestion': suggestion ?? '',
            }),
          )
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
