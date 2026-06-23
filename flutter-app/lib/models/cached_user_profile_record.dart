import 'package:read_the_label/core/constants/database_constants.dart';
import 'package:read_the_label/models/user_profile.dart';

class CachedUserProfileRecord {
  final String userId;
  final UserProfile profile;
  final DateTime cachedAt;

  CachedUserProfileRecord({
    required this.userId,
    required this.profile,
    required this.cachedAt,
  });

  bool get isExpired {
    final difference = DateTime.now().difference(cachedAt);
    return difference.inDays >= 1; // 1-day TTL
  }

  factory CachedUserProfileRecord.fromDbMap(
      Map<String, dynamic> dbMap, Map<String, dynamic> profileJson) {
    return CachedUserProfileRecord(
      userId: dbMap[DatabaseConstants.columnUserId] as String,
      profile: UserProfile.fromJson(profileJson),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(
          dbMap[DatabaseConstants.columnCachedAt] as int),
    );
  }

  Map<String, dynamic> toDbMap(String profileJsonStr) {
    return {
      DatabaseConstants.columnUserId: userId,
      DatabaseConstants.columnProfileJson: profileJsonStr,
      DatabaseConstants.columnCachedAt: cachedAt.millisecondsSinceEpoch,
    };
  }
}
