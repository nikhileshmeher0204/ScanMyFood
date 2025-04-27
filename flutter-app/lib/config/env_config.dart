import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:read_the_label/firebase_options.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load(fileName: ".env");
  }

  static String? getApiKey() {
    return dotenv.env['GEMINI_API_KEY'];
  }
}
