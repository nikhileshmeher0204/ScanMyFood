class DatabaseConstants {
  static const String dbName = 'local_cache.db';
  static const int dbVersion = 2;

  // Tables
  static const String tableUserProfile = 'user_profile_cache';
  static const String tableDailyIntake = 'daily_intake_cache';
  static const String tableAiChatSessions = 'ai_chat_sessions';
  static const String tableAiChatMessages = 'ai_chat_messages';

  // Columns
  static const String columnUserId = 'user_id';
  static const String columnProfileJson = 'profile_json';
  static const String columnCachedAt = 'cached_at';

  static const String columnDateKey = 'date_key';
  static const String columnDataJson = 'data_json';

  // AI Chat Columns
  static const String columnSessionId = 'session_id';
  static const String columnTitle = 'title';
  static const String columnMealContext = 'meal_context';
  static const String columnCreatedAt = 'created_at';
  static const String columnLastMsgAt = 'last_msg_at';

  static const String columnMessageId = 'id';
  static const String columnRole = 'role';
  static const String columnContentJson = 'content_json';
}
