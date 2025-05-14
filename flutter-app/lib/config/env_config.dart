import 'package:firebase_core/firebase_core.dart';
import 'package:read_the_label/firebase_options.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
