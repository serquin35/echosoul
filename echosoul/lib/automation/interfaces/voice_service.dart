import '../../features/companion/domain/entities/voice_call_event.dart';

/// Abstract contract for voice call services (Vapi.ai implementation).
abstract class VoiceService {
  /// Start an on-demand voice call from within the app (WebRTC).
  Future<void> startInAppCall({
    required String userId,
    required String companionName,
    required String userName,
    String? firstMessage,
  });

  /// End the current active call.
  Future<void> endCall();

  /// Stream of call events (status changes, transcripts, etc.)
  Stream<VoiceCallEvent> get callEvents;

  /// Whether a call is currently active.
  bool get isCallActive;
}
