class DatabaseConstants {
  static const String dbName = 'local_cache.db';
  static const int dbVersion = 1;

  // Tables
  static const String tableUserProfile = 'user_profile_cache';
  static const String tableDailyIntake = 'daily_intake_cache';

  // Columns
  static const String columnUserId = 'user_id';
  static const String columnProfileJson = 'profile_json';
  static const String columnCachedAt = 'cached_at';

  static const String columnDateKey = 'date_key';
  static const String columnDataJson = 'data_json';
}
