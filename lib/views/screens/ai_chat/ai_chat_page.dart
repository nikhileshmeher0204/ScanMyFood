import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late GeminiProvider _provider;
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

  GeminiProvider _createProvider([List<ChatMessage>? history]) {
    return GeminiProvider(
      history: history,
      model: GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        systemInstruction: Content.system('''
          You are a helpful friendly assistant specialized in providing nutritional information and guidance about food and health.
          Answer questions clearly and keep responses concise. Use emojis to make the text more user-friendly and engaging.
        '''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: "Chat with AI"),
      body: !_isProviderInitialized
          ? const Center(child: CircularProgressIndicator())
          : _buildChatSection(),
    );
  }

  Widget _buildChatSection() {
    return LlmChatView(
      provider: _provider,
      welcomeMessage: "👋 Hello! I'm your nutrition and health assistant. How can I help you today? 🍎",
      style: _buildChatViewStyle(),
    );
  }

  LlmChatViewStyle _buildChatViewStyle() {
    return LlmChatViewStyle(
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
        iconColor: Colors.white,
      ),
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