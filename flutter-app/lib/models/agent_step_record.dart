class AgentStepRecord {
  final String toolName;
  final String humanLabel;
  final bool success;
  final DateTime completedAt;

  AgentStepRecord({
    required this.toolName,
    required this.humanLabel,
    required this.success,
    required this.completedAt,
  });

  factory AgentStepRecord.fromJson(Map<String, dynamic> json) {
    return AgentStepRecord(
      toolName: json['toolName'] as String,
      humanLabel: json['humanLabel'] as String,
      success: json['success'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolName': toolName,
      'humanLabel': humanLabel,
      'success': success,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
