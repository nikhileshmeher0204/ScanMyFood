import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:read_the_label/firebase_options.dart';

/// Centralized Environment Configuration Manager
/// Supports multi-profile environment configs (.env.local, .env.uat, .env.prod, .env)
/// Select profile via command line:
///   - Local: `flutter run --dart-define=ENV=local`
///   - UAT:   `flutter run --dart-define=ENV=uat`
///   - Prod:  `flutter run --dart-define=ENV=prod`
class EnvConfig {
  static const String _envDefine =
      String.fromEnvironment('ENV', defaultValue: '');

  static Future<void> initialize() async {
    String fileName = '.env';
    if (_envDefine.isNotEmpty) {
      fileName = '.env.${_envDefine.toLowerCase()}';
    }

    try {
      await dotenv.load(fileName: fileName);
      debugPrint('Loaded environment config: $fileName');
    } catch (e) {
      debugPrint(
          'Failed to load $fileName ($e). Falling back to default .env');
      try {
        await dotenv.load(fileName: '.env');
      } catch (fallbackErr) {
        debugPrint('Warning: Could not load .env file: $fallbackErr');
      }
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Current environment profile name ('local', 'uat', 'prod')
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ??
      (_envDefine.isNotEmpty ? _envDefine : 'local');

  /// Base API URL for backend calls
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:8080/api',
      );

  /// Gemini API Key
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ??
      const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Whether debug logging is enabled
  static bool get isDebugLogsEnabled =>
      dotenv.env['ENABLE_DEBUG_LOGS']?.toLowerCase() == 'true' || kDebugMode;

  /// Environment profile helpers
  static bool get isLocal => environment.toLowerCase() == 'local';
  static bool get isUat => environment.toLowerCase() == 'uat';
  static bool get isProd => environment.toLowerCase() == 'prod';
}
