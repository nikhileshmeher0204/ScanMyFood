import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';

class AskAiPage extends StatefulWidget {
  final String mealName;
  final File? foodImage;
  const AskAiPage({
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
  late String _currentMealName;

  @override
  void initState() {
    super.initState();
    _currentMealName = widget.mealName;
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
    _updateProviderIfNeeded();

    return Scaffold(
      appBar: const PrimaryAppBar(title: "Ask AI"),
      body: !_isProviderInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFoodImageSection(),
                Expanded(child: _buildChatSection()),
              ],
            ),
    );
  }

  Widget _buildFoodImageSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          _buildBaseImage(),
          _buildBlurredImage(),
          Positioned(
            left: 16,
            right: 16,
            bottom: 2,
            child: Text(
              widget.mealName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseImage() {
    return widget.foodImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: FileImage(widget.foodImage!),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              width: double.infinity,
              height: 200,
            ),
          )
        : Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
          );
  }

  Widget _buildBlurredImage() {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black.withOpacity(0)],
            stops: const [0.4, 0.75],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: _buildBaseImage(),
      ),
    );
  }

  Widget _buildChatSection() {
    return LlmChatView(
      suggestions: const [
        '🍽️ Is this meal balanced?',
        '🍊 Is this meal rich in vitamins?',
        '🏋️‍♂️ Is this meal good for weight loss?',
        '💪 How does this meal support muscle growth?',
        '🌟 What are the health benefits of this meal?',
      ],
      provider: _provider,
      welcomeMessage:
          "👋 Hello, what would you like to know about $_currentMealName? 🍽️",
      style: _buildChatViewStyle(),
    );
  }

  void _updateProviderIfNeeded() {
    final mealName = context.watch<MealAnalysisViewModel>().mealName;
    if (mealName != _currentMealName) {
      _currentMealName = mealName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _provider = _createProvider();
        });
      });
    }
  }

  LlmChatViewStyle _buildChatViewStyle() {
    return LlmChatViewStyle(
      suggestionStyle: SuggestionStyle(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          )),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actionButtonBarDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
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
        backgroundColor: Theme.of(context).colorScheme.cardBackground,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      llmMessageStyle: LlmMessageStyle(
          markdownStyle: MarkdownStyleSheet.fromTheme(Theme.of(context)),
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
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
    );
  }
}
