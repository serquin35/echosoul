// Mood feature entity — placeholder

class MoodEntryEntity {
  final String id;
  final String userId;
  final int? moodScore; // 1-10
  final String? moodLabel; // 'triste', 'ansioso', 'bien', etc.
  final String? notes;
  final String triggeredBy; // 'scheduled', 'user_initiated', 'crisis_detected'
  final DateTime createdAt;

  const MoodEntryEntity({
    required this.id,
    required this.userId,
    this.moodScore,
    this.moodLabel,
    this.notes,
    this.triggeredBy = 'user_initiated',
    required this.createdAt,
  });

  factory MoodEntryEntity.fromJson(Map<String, dynamic> json) {
    return MoodEntryEntity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      moodScore: (json['mood_score'] as num?)?.toInt(),
      moodLabel: json['mood_label'] as String?,
      notes: json['notes'] as String?,
      triggeredBy: json['triggered_by'] as String? ?? 'user_initiated',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'mood_score': moodScore,
      'mood_label': moodLabel,
      'notes': notes,
      'triggered_by': triggeredBy,
    };
  }

  bool get isCritical => moodScore != null && moodScore! <= 2;
  bool get isLow => moodScore != null && moodScore! <= 4;
  bool get isPositive => moodScore != null && moodScore! >= 7;
}
