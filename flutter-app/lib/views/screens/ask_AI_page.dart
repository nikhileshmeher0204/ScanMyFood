import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';

class AskAiPage extends StatefulWidget {
  String mealName;
  File? foodImage;
  AskAiPage({
    super.key,
    required this.mealName,
    required this.foodImage,
  });

  @override
  State<AskAiPage> createState() => _AskAiPageState();
}

class _AskAiPageState extends State<AskAiPage> {
  late GeminiProvider _provider;
  String? nutritionContext;
  String? apiKey;
  bool _isProviderInitialized = false;

  @override
  void initState() {
    super.initState();
    apiKey = kIsWeb
        ? const String.fromEnvironment('GEMINI_API_KEY')
        : dotenv.env['GEMINI_API_KEY'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() {
    if (!mounted) return;

    setState(() {
      _provider = _createProvider();
      _isProviderInitialized = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  GeminiProvider _createProvider([List<ChatMessage>? history]) {
    // Safe provider access - only after widget is built
    final mealAnalysisProvider =
        Provider.of<MealAnalysisViewModel>(context, listen: false);

    // Add null safety for all accessed values
    final calories = mealAnalysisProvider.totalPlateNutrients['calories'] ?? 0;
    final protein = mealAnalysisProvider.totalPlateNutrients['protein'] ?? 0;
    final carbs =
        mealAnalysisProvider.totalPlateNutrients['carbohydrates'] ?? 0;
    final fat = mealAnalysisProvider.totalPlateNutrients['fat'] ?? 0;
    final fiber = mealAnalysisProvider.totalPlateNutrients['fiber'] ?? 0;

    nutritionContext = '''
      Meal: ${widget.mealName}
      Nutritional Information:
      - Calories: $calories kcal
      - Protein: ${protein}g
      - Carbohydrates: ${carbs}g
      - Fat: ${fat}g
      - Fiber: ${fiber}g
    ''';

    print('🍊Nutrition Context: $nutritionContext');

    return GeminiProvider(
      history: history,
      model: GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        systemInstruction: Content.system('''
          You are a helpful friendly assistant specialized in providing nutritional information and guidance about meals.
          
          Current meal context:
          $nutritionContext
          
          Base your answers on this specific nutritional data when discussing this meal.
            Answer questions clearly, with relevant icons, and keep responses concise. Use emojis to make the text more user-friendly and engaging.
        '''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isProviderInitialized) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          title: const Text('Ask AI'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    void _updateProvider() {
      if (!mounted) return;

      setState(() {
        _provider = _createProvider();
      });
    }

    final mealName = context.watch<MealAnalysisViewModel>().mealName;
    if (mealName != widget.mealName) {
      widget.mealName = mealName;
      // Schedule update for next frame to avoid rebuild during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateProvider();
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: const Text('Ask AI'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  widget.foodImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: FileImage(widget.foodImage!),
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                            width: double.infinity,
                            height: 200,
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.black.withOpacity(0)],
                            stops: const [0.4, 0.75]).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,
                      child: widget.foodImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: FileImage(widget.foodImage!),
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                                width: double.infinity,
                                height: 200,
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 2,
                    child: Text(
                      widget.mealName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 400,
              width: MediaQuery.of(context).size.width,
              child: LlmChatView(
                suggestions: const [
                  '🍽️ Is this meal balanced?',
                  '🍊 Is this meal rich in vitamins?',
                  '🏋️‍♂️ Is this meal good for weight loss?',
                  '💪 How does this meal support muscle growth?',
                  '🌟 What are the health benefits of this meal?',
                ],
                provider: _provider,
                welcomeMessage:
                    "👋 Hello, what would you like to know about ${widget.mealName}? 🍽️",
                style: LlmChatViewStyle(
                  suggestionStyle: SuggestionStyle(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.cardBackground,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: <Color>[
                              Color.fromARGB(255, 0, 21, 255),
                              Color.fromARGB(255, 255, 0, 85),
                              Color.fromARGB(255, 255, 119, 0),
                              Color.fromARGB(255, 250, 220, 194),
                            ],
                            stops: [
                              0.1,
                              0.5,
                              0.7,
                              1.0,
                            ], // Four stops for four colors
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 250.0, 16.0),
                          ),
                      )),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  actionButtonBarDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  addButtonStyle: ActionButtonStyle(
                    iconColor: Theme.of(context).colorScheme.onSurface,
                    iconDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.cardBackground,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  chatInputStyle: ChatInputStyle(
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.cardBackground,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  llmMessageStyle: LlmMessageStyle(
                      markdownStyle:
                          MarkdownStyleSheet.fromTheme(Theme.of(context)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.cardBackground,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      iconDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      iconColor: Colors.white),
                  userMessageStyle: UserMessageStyle(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.cardBackground,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
