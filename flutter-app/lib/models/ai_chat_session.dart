class AiChatSession {
  final String sessionId;
  final String title;
  final String? mealContext;
  final DateTime createdAt;
  final DateTime lastMsgAt;

  AiChatSession({
    required this.sessionId,
    required this.title,
    this.mealContext,
    required this.createdAt,
    required this.lastMsgAt,
  });

  factory AiChatSession.fromMap(Map<String, dynamic> map) {
    return AiChatSession(
      sessionId: map['session_id'] as String,
      title: map['title'] as String,
      mealContext: map['meal_context'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastMsgAt: DateTime.fromMillisecondsSinceEpoch(map['last_msg_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'title': title,
      'meal_context': mealContext,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_msg_at': lastMsgAt.millisecondsSinceEpoch,
    };
  }

  AiChatSession copyWith({
    String? sessionId,
    String? title,
    String? mealContext,
    DateTime? createdAt,
    DateTime? lastMsgAt,
  }) {
    return AiChatSession(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      mealContext: mealContext ?? this.mealContext,
      createdAt: createdAt ?? this.createdAt,
      lastMsgAt: lastMsgAt ?? this.lastMsgAt,
    );
  }
}
