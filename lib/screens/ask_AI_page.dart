import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_the_label/logic.dart';
import 'package:read_the_label/main.dart';

class AskAiPage extends StatefulWidget {
  String mealName;
  File? foodImage;
  final Logic logic;
  AskAiPage(
      {super.key,
      required this.mealName,
      required this.foodImage,
      required this.logic});

  @override
  State<AskAiPage> createState() => _AskAiPageState();
}

class _AskAiPageState extends State<AskAiPage> {
  late final GeminiProvider _provider;
  late String nutritionContext;
  String? _currentMealName;

  final apiKey = kIsWeb
      ? const String.fromEnvironment('GEMINI_API_KEY')
      : dotenv.env['GEMINI_API_KEY'];

  @override
  void initState() {
    super.initState();
    _currentMealName = widget.mealName;
    _provider = _createProvider();
    widget.logic.mealNameNotifier.addListener(_onMealNameChange);
  }

  void _onMealNameChange() {
    if (widget.logic.mealName != _currentMealName) {
      setState(() {
        _currentMealName = widget.logic.mealName;
        // Create new provider with empty history
        _provider = _createProvider();
      });
    }
  }

  @override
  void dispose() {
    widget.logic.mealNameNotifier.removeListener(_onMealNameChange);
    super.dispose();
  }

  GeminiProvider _createProvider([List<ChatMessage>? history]) {
    nutritionContext = '''
      Meal: ${widget.mealName}
      Nutritional Information:
      - Calories: ${widget.logic.totalPlateNutrients['calories']} kcal
      - Protein: ${widget.logic.totalPlateNutrients['protein']}g
      - Carbohydrates: ${widget.logic.totalPlateNutrients['carbohydrates']}g
      - Fat: ${widget.logic.totalPlateNutrients['fat']}g
      - Fiber: ${widget.logic.totalPlateNutrients['fiber']}g
    ''';

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
