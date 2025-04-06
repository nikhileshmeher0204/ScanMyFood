import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  static String? getApiKey() {
    return dotenv.env['GEMINI_API_KEY'];
  }
}
