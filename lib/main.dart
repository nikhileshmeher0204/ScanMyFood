import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:read_the_label/config/env_config.dart';
import 'package:read_the_label/repositories/ai_repository.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'views/screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

  await EnvConfig.initialize();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _registerProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: const HomePage(),
      ),
    );
  }

  List<SingleChildWidget> _registerProviders() {
    return [
      // Register repositories first
      Provider<AiRepository>(
        create: (_) => AiRepository(),
      ),
      Provider<StorageRepository>(
        create: (_) => StorageRepository(),
      ),

      // Register ViewModels
      ChangeNotifierProvider<UiViewModel>(
        create: (_) => UiViewModel(),
      ),
      // Keep these changes:
      ChangeNotifierProxyProvider<UiViewModel, ProductAnalysisViewModel>(
        create: (context) => ProductAnalysisViewModel(
          aiRepository: context.read<AiRepository>(),
          uiProvider: context.read<UiViewModel>(),
        ),
        update: (context, uiViewModel, previous) =>
            previous!..uiProvider = uiViewModel,
      ),
      ChangeNotifierProxyProvider<UiViewModel, MealAnalysisViewModel>(
        create: (context) => MealAnalysisViewModel(
          aiRepository: context.read<AiRepository>(),
          uiProvider: context.read<UiViewModel>(),
        ),
        update: (context, uiViewModel, previous) =>
            previous!..uiProvider = uiViewModel,
      ),
      ChangeNotifierProxyProvider2<UiViewModel, StorageRepository,
          DailyIntakeViewModel>(
        create: (context) => DailyIntakeViewModel(
          storageRepository: context.read<StorageRepository>(),
          uiProvider: context.read<UiViewModel>(),
        ),
        update: (context, uiViewModel, storageRepository, previous) => previous!
          ..uiProvider = uiViewModel
          ..storageRepository = storageRepository,
      ),
    ];
  }
}
