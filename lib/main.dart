import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'my_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  if (kIsWeb) {
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=your_api_key');
  } else {
    await dotenv.load(fileName: ".env");
  }
  runApp(const MyApp());
}

extension CustomColors on ColorScheme {
  Color get accent => const Color(0xFF61DAFB);
  Color get neutral => const Color(0xFF808080);
  Color get success => const Color(0xFF4CAF50);
  Color get warning => const Color(0xFFFFA726);
  Color get info => const Color(0xFF29B6F6);
  Color get background => const Color(0xFF121212);
  Color get cardBackground => const Color(0xFF1E1E1E);
  Color get divider => const Color(0xFF2D2D2D);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7BFF),
          brightness: Brightness.light,
          surface: const Color(0xFF121212),
          primary: const Color(0xFF4E7BFF),
          secondary: const Color(0xFF9C72FF),
          tertiary: const Color.fromARGB(
              255, 220, 109, 190), // Changed to a bright green color
          error: const Color(0xFFFF5C5C),
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.black),
          labelMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
