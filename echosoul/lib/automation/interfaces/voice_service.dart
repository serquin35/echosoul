/// Abstract contract for voice call services (Vapi.ai implementation).
abstract class VoiceService {
  /// Initiate a proactive outbound call to the user.
  Future<void> startOutboundCall({
    required String userId,
    required String toPhoneNumber,
    required String callType,       // 'morning' | 'evening' | 'crisis' | 'weekly'
    Map<String, String>? dynamicVariables,
  });

  /// End an active call.
  Future<void> endCall({required String callId});

  /// Check if a call is currently active for this user.
  Future<bool> isCallActive({required String userId});
}
