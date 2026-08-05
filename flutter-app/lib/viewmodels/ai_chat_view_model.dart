import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:read_the_label/models/ai_chat_session.dart';
import 'package:read_the_label/models/agent_step_record.dart';
import 'package:read_the_label/models/user_profile.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/services/local_database_service.dart';
import 'package:read_the_label/services/ai_chat_service.dart';
import 'package:read_the_label/services/tools/tool_execution_client.dart';
import 'base_view_model.dart';
import 'package:read_the_label/main.dart';

enum ChatItemType {
  userText,
  aiText,
  surface,
  steps,
}

class ChatItem {
  final String id;
  final ChatItemType type;
  final String text;
  final String? surfaceId;
  final List<AgentStepRecord>? steps;
  final DateTime timestamp;

  ChatItem({
    required this.id,
    required this.type,
    this.text = '',
    this.surfaceId,
    this.steps,
    required this.timestamp,
  });
}

class AiChatViewModel extends BaseViewModel {
  final UserRepository userRepository;
  final AuthService authService;
  final ToolExecutionClient toolClient;

  List<AiChatSession> _sessions = [];
  AiChatSession? _currentSession;
  List<ChatItem> _chatItems = [];
  List<AgentStepRecord> _activeSteps = [];
  bool _isLoading = false;

  bool _isAgentRunning = false;
  String? _currentRunningLabel;

  StreamSubscription<AgentStepEvent>? _stepEventsSub;

  AiChatViewModel({
    required this.userRepository,
    required this.authService,
    required this.toolClient,
  }) {
    _listenToStepEvents();
  }

  List<AiChatSession> get sessions => _sessions;
  AiChatSession? get currentSession => _currentSession;
  List<ChatItem> get chatItems => _chatItems;
  List<AgentStepRecord> get activeSteps => _activeSteps;
  bool get isLoading => _isLoading;

  bool get isAgentRunning => _isAgentRunning;
  String? get currentRunningLabel => _currentRunningLabel;

  void _listenToStepEvents() {
    _stepEventsSub?.cancel();
    _stepEventsSub = AiChatService.instance.stepEvents.listen((event) {
      if (event.sessionId != _currentSession?.sessionId) return;

      if (event.isRunning) {
        _isAgentRunning = true;
        _currentRunningLabel = event.label;
      }

      final stepIdx = _activeSteps.indexWhere((s) => s.toolName == event.toolName);
      if (stepIdx != -1) {
        _activeSteps[stepIdx] = AgentStepRecord(
          toolName: event.toolName,
          humanLabel: event.label,
          success: event.success,
          completedAt: event.timestamp,
        );
      } else {
        _activeSteps.add(AgentStepRecord(
          toolName: event.toolName,
          humanLabel: event.label,
          success: event.success,
          completedAt: event.timestamp,
        ));
      }

      // Update or add ChatItemType.steps at the bottom
      final chatStepIdx = _chatItems.indexWhere((item) =>
          item.type == ChatItemType.steps &&
          item.steps != null &&
          item.steps!.any((s) =>
              s.toolName == event.toolName ||
              _activeSteps.any((as) => as.toolName == s.toolName)));
      if (chatStepIdx != -1) {
        _chatItems[chatStepIdx] = ChatItem(
          id: _chatItems[chatStepIdx].id,
          type: ChatItemType.steps,
          steps: List.from(_activeSteps),
          timestamp: DateTime.now(),
        );
      } else {
        _chatItems.add(ChatItem(
          id: const Uuid().v4(),
          type: ChatItemType.steps,
          steps: List.from(_activeSteps),
          timestamp: DateTime.now(),
        ));
      }
      notifyListeners();
    });
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await LocalDatabaseService.instance.getSessions();
    } catch (e) {
      setError('Failed to load chat history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startNewSession({String? mealContext}) async {
    final sessionId = const Uuid().v4();
    final newSession = AiChatSession(
      sessionId: sessionId,
      title: mealContext != null ? 'Meal Scan Context Chat' : 'New AI Chat',
      mealContext: mealContext,
      createdAt: DateTime.now(),
      lastMsgAt: DateTime.now(),
    );

    try {
      await LocalDatabaseService.instance.createSession(newSession);
      _currentSession = newSession;
      _chatItems = [];
      _activeSteps = [];
      await loadSessions();
      notifyListeners();
    } catch (e) {
      setError('Failed to start new session: $e');
    }
  }

  Future<void> loadSession(String sessionId) async {
    _activeSteps = [];
    final idx = _sessions.indexWhere((s) => s.sessionId == sessionId);
    if (idx != -1) {
      _currentSession = _sessions[idx];
    } else {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final dbMessages = await LocalDatabaseService.instance.getSessionMessages(sessionId);

      _chatItems = [];
      for (final msg in dbMessages) {
        if (msg.role == ChatMessageRole.system) continue;

        // Check if message content has surfaces or text
        final type = msg.role == ChatMessageRole.user ? ChatItemType.userText : ChatItemType.aiText;

        // Check if there are surface parts in this message
        bool hasSurface = false;
        for (final part in msg.parts) {
          if (part.isUiPart) {
            hasSurface = true;
            _chatItems.add(ChatItem(
              id: const Uuid().v4(),
              type: ChatItemType.surface,
              surfaceId: part.asUiPart?.surfaceId ?? '',
              timestamp: DateTime.now(),
            ));
          }
        }

        if (msg.text.isNotEmpty || !hasSurface) {
          _chatItems.add(ChatItem(
            id: const Uuid().v4(),
            type: type,
            text: msg.text,
            timestamp: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      setError('Failed to load session messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await LocalDatabaseService.instance.deleteSession(sessionId);
      if (_currentSession?.sessionId == sessionId) {
        _currentSession = null;
        _chatItems = [];
        _activeSteps = [];
      }
      await loadSessions();
    } catch (e) {
      setError('Failed to delete session: $e');
    }
  }

  /// Appends a user message to the UI log, and starts processMessage.
  Future<void> sendUserMessage(String text, A2uiTransportAdapter transport) async {
    if (_currentSession == null) {
      await startNewSession();
    }

    final session = _currentSession!;
    final userMessage = ChatMessage.user(text);

    // Add local user message item to UI
    _chatItems.add(ChatItem(
      id: const Uuid().v4(),
      type: ChatItemType.userText,
      text: text,
      timestamp: DateTime.now(),
    ));
    _activeSteps = [];
    _isAgentRunning = false;
    _currentRunningLabel = null;
    notifyListeners();

    // Fetch user profile for context building
    UserProfile? profile;
    try {
      final user = authService.currentUser;
      if (user != null) {
        profile = await userRepository.getUserProfile();
      }
    } catch (e) {
      logger.w('Failed to load user profile for chat context: $e');
    }

    // Call service to process message and await it to handle loader state
    try {
      await AiChatService.instance.processMessage(
        sessionId: session.sessionId,
        userMessage: userMessage,
        transport: transport,
        toolClient: toolClient,
        profile: profile,
        mealScanContext: session.mealContext,
      );
    } finally {
      _isAgentRunning = false;
      _currentRunningLabel = null;
      notifyListeners();
    }
  }

  void appendAiText(String text) {
    // Check if the last item is ChatItemType.aiText. If so, append to it.
    // If not, create a new one.
    if (_chatItems.isNotEmpty && _chatItems.last.type == ChatItemType.aiText) {
      final lastItem = _chatItems.last;
      _chatItems[_chatItems.length - 1] = ChatItem(
        id: lastItem.id,
        type: ChatItemType.aiText,
        text: lastItem.text + text,
        timestamp: lastItem.timestamp,
      );
    } else {
      _chatItems.add(ChatItem(
        id: const Uuid().v4(),
        type: ChatItemType.aiText,
        text: text,
        timestamp: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  void appendSurface(String surfaceId) {
    _chatItems.add(ChatItem(
      id: const Uuid().v4(),
      type: ChatItemType.surface,
      surfaceId: surfaceId,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void dispose() {
    _stepEventsSub?.cancel();
    super.dispose();
  }
}
