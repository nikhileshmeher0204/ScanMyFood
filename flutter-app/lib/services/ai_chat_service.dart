import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart' as fbai;
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
import 'package:uuid/uuid.dart';
import 'package:read_the_label/models/ai_chat_session.dart';
import 'package:read_the_label/models/user_profile.dart';
import 'package:read_the_label/services/local_database_service.dart';
import 'package:read_the_label/services/ai_context_builder.dart';
import 'package:read_the_label/main.dart';

class AgentStepEvent {
  final String sessionId;
  final String toolName;
  final String label;
  final bool isRunning;
  final bool success;
  final DateTime timestamp;

  AgentStepEvent({
    required this.sessionId,
    required this.toolName,
    required this.label,
    required this.isRunning,
    this.success = true,
    required this.timestamp,
  });
}

class AiChatService {
  static final AiChatService instance = AiChatService._init();

  final _activeSessions = <String, fbai.ChatSession>{};
  final _stepEventsController = StreamController<AgentStepEvent>.broadcast();

  AiChatService._init();

  Stream<AgentStepEvent> get stepEvents => _stepEventsController.stream;

  fbai.Content _chatMessageToFirebaseContent(ChatMessage msg) {
    final parts = <fbai.Part>[];
    for (final part in msg.parts) {
      if (part is genui.TextPart) {
        parts.add(fbai.TextPart(part.text));
      }
    }
    return fbai.Content(
      msg.role == ChatMessageRole.user ? 'user' : 'model',
      parts,
    );
  }

  Future<fbai.ChatSession> _getOrCreateChatSession(
    String sessionId, {
    String? mealScanContext,
    UserProfile? profile,
  }) async {
    if (_activeSessions.containsKey(sessionId)) {
      return _activeSessions[sessionId]!;
    }

    // Build system instruction
    final systemPrompt = AiContextBuilder.buildSystemPrompt(
      profile: profile,
      mealScanContext: mealScanContext,
    );

    final model = fbai.FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: fbai.Content.system(systemPrompt),
    );

    // Load past messages from database
    final dbMessages = await LocalDatabaseService.instance.getSessionMessages(
      sessionId,
    );

    // Map to Firebase AI Content history
    final history = dbMessages
        .where((m) => m.role != ChatMessageRole.system)
        .map(_chatMessageToFirebaseContent)
        .toList();

    final chatSession = model.startChat(history: history);

    _activeSessions[sessionId] = chatSession;
    return chatSession;
  }

  /// Sends a message and processes the response.
  /// Emits step events during the loop (mainly in Phase 2, but stubbed here).
  Future<void> processMessage({
    required String sessionId,
    required ChatMessage userMessage,
    required A2uiTransportAdapter transport,
    UserProfile? profile,
    String? mealScanContext,
  }) async {
    final db = LocalDatabaseService.instance;
    final messageId = const Uuid().v4();

    // 1. Save user message to database
    await db.saveMessage(sessionId, messageId, userMessage);
    await db.updateSessionLastMsgAt(sessionId, DateTime.now());

    try {
      final chatSession = await _getOrCreateChatSession(
        sessionId,
        mealScanContext: mealScanContext,
        profile: profile,
      );

      // In Phase 2 we will handle the tool call execution loop here.
      // For Phase 1, we do a direct sendMessage.
      final response = await chatSession.sendMessage(
        _chatMessageToFirebaseContent(userMessage),
      );

      final aiText = response.text ?? '';
      if (aiText.isNotEmpty) {
        transport.addChunk(aiText);

        // 2. Save model response to database
        final aiMessageId = const Uuid().v4();
        final aiMessage = ChatMessage.model(aiText);
        await db.saveMessage(sessionId, aiMessageId, aiMessage);
        await db.updateSessionLastMsgAt(sessionId, DateTime.now());
      }
    } catch (e, stack) {
      logger.e('Error processing message in session $sessionId: $e', e, stack);
      transport.addChunk(
        'Sorry, I encountered an error processing your request. Please try again.',
      );
    }
  }

  void clearSessionCache(String sessionId) {
    _activeSessions.remove(sessionId);
  }
}
