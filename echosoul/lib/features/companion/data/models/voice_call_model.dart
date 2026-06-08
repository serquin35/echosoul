import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_call_model.freezed.dart';
part 'voice_call_model.g.dart';

@freezed
class VoiceCallModel with _$VoiceCallModel {
  const factory VoiceCallModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'vapi_call_id') String? vapiCallId,
    @JsonKey(name: 'call_type') required String callType,
    required String status,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'mood_score_during') int? moodScoreDuring,
    @JsonKey(name: 'call_summary') String? callSummary,
    @JsonKey(name: 'crisis_detected') @Default(false) bool crisisDetected,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _VoiceCallModel;

  factory VoiceCallModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallModelFromJson(json);
}
