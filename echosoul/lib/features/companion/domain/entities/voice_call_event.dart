/// Represents events emitted during a voice call session.
///
/// UI tonta: The VoiceCallScreen observes these events via the provider
/// and renders state accordingly — it never calls Vapi directly.
sealed class VoiceCallEvent {
  const VoiceCallEvent();
}

/// Call is being initiated / connecting.
class VoiceCallConnecting extends VoiceCallEvent {
  const VoiceCallConnecting();
}

/// Call has started — audio is flowing.
class VoiceCallStarted extends VoiceCallEvent {
  const VoiceCallStarted();
}

/// The assistant is currently speaking.
class VoiceCallSpeechUpdate extends VoiceCallEvent {
  final String role; // 'assistant' or 'user'
  final String status; // 'started' or 'stopped'

  const VoiceCallSpeechUpdate({
    required this.role,
    required this.status,
  });
}

/// A transcript fragment was received.
class VoiceCallTranscript extends VoiceCallEvent {
  final String role; // 'assistant' or 'user'
  final String text;
  final bool isFinal;

  const VoiceCallTranscript({
    required this.role,
    required this.text,
    this.isFinal = false,
  });
}

/// Call ended normally.
class VoiceCallEnded extends VoiceCallEvent {
  const VoiceCallEnded();
}

/// An error occurred during the call.
class VoiceCallError extends VoiceCallEvent {
  final String message;

  const VoiceCallError({required this.message});
}
