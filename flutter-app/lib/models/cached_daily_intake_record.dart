import 'package:read_the_label/core/constants/database_constants.dart';
import 'package:read_the_label/models/user_intake_output.dart';

class CachedDailyIntakeRecord {
  final String userId;
  final String dateKey;
  final DailyIntakeData data;
  final DateTime cachedAt;

  CachedDailyIntakeRecord({
    required this.userId,
    required this.dateKey,
    required this.data,
    required this.cachedAt,
  });

  bool get isExpired {
    final difference = DateTime.now().difference(cachedAt);
    return difference.inDays >= 1; // 1-day TTL
  }

  factory CachedDailyIntakeRecord.fromDbMap(
      Map<String, dynamic> dbMap, Map<String, dynamic> dataJson) {
    return CachedDailyIntakeRecord(
      userId: dbMap[DatabaseConstants.columnUserId] as String,
      dateKey: dbMap[DatabaseConstants.columnDateKey] as String,
      data: DailyIntakeData.fromJson(dataJson),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(
          dbMap[DatabaseConstants.columnCachedAt] as int),
    );
  }

  Map<String, dynamic> toDbMap(String dataJsonStr) {
    return {
      DatabaseConstants.columnUserId: userId,
      DatabaseConstants.columnDateKey: dateKey,
      DatabaseConstants.columnDataJson: dataJsonStr,
      DatabaseConstants.columnCachedAt: cachedAt.millisecondsSinceEpoch,
    };
  }
}
