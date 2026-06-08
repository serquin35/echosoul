import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../automation/interfaces/voice_service.dart';
import '../../data/repositories/vapi_voice_repository.dart';
import '../../domain/entities/voice_call_event.dart';

// Provides the singleton instance of the voice repository
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final repository = VapiVoiceRepository(Supabase.instance.client);
  ref.onDispose(() => repository.dispose());
  return repository;
});

enum VoiceCallStatus { idle, connecting, active, ending, ended, error }

class VoiceCallState {
  final VoiceCallStatus status;
  final Duration callDuration;
  final String? currentTranscript;
  final bool isMuted;
  final bool isSpeakerOn;
  final String? errorMessage;
  final String? speakerRole; // 'assistant' or 'user'

  const VoiceCallState({
    this.status = VoiceCallStatus.idle,
    this.callDuration = Duration.zero,
    this.currentTranscript,
    this.isMuted = false,
    this.isSpeakerOn = true,
    this.errorMessage,
    this.speakerRole,
  });

  VoiceCallState copyWith({
    VoiceCallStatus? status,
    Duration? callDuration,
    String? currentTranscript,
    bool? isMuted,
    bool? isSpeakerOn,
    String? errorMessage,
    String? speakerRole,
  }) {
    return VoiceCallState(
      status: status ?? this.status,
      callDuration: callDuration ?? this.callDuration,
      currentTranscript: currentTranscript ?? this.currentTranscript,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      errorMessage: errorMessage ?? this.errorMessage,
      speakerRole: speakerRole ?? this.speakerRole,
    );
  }
}

class VoiceCallNotifier extends StateNotifier<VoiceCallState> {
  final VoiceService _voiceService;
  StreamSubscription? _eventsSubscription;
  Timer? _durationTimer;

  VoiceCallNotifier(this._voiceService) : super(const VoiceCallState());

  Future<void> startCall(String userId, String companionName, String userName, {String? firstMessage}) async {
    // 1. Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      state = state.copyWith(
        status: VoiceCallStatus.error,
        errorMessage: 'Microphone permission is required for voice calls.',
      );
      return;
    }

    state = state.copyWith(
      status: VoiceCallStatus.connecting,
      errorMessage: null,
      callDuration: Duration.zero,
    );

    // 2. Subscribe to events
    _eventsSubscription?.cancel();
    _eventsSubscription = _voiceService.callEvents.listen(_handleEvent);

    // 3. Initiate call
    await _voiceService.startInAppCall(
      userId: userId,
      companionName: companionName,
      userName: userName,
      firstMessage: firstMessage,
    );
  }

  Future<void> endCall() async {
    state = state.copyWith(status: VoiceCallStatus.ending);
    await _voiceService.endCall();
    _stopTimer();
  }

  void toggleMute() {
    // Note: To implement real mute, we'd need Vapi SDK mute support 
    // For now we just update UI state. If Vapi adds mute, call it here.
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleSpeaker() {
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  void _handleEvent(VoiceCallEvent event) {
    if (event is VoiceCallConnecting) {
      state = state.copyWith(status: VoiceCallStatus.connecting);
    } else if (event is VoiceCallStarted) {
      state = state.copyWith(status: VoiceCallStatus.active);
      _startTimer();
    } else if (event is VoiceCallSpeechUpdate) {
      if (event.status == 'started') {
        state = state.copyWith(speakerRole: event.role);
      } else {
        if (state.speakerRole == event.role) {
          state = state.copyWith(speakerRole: null);
        }
      }
    } else if (event is VoiceCallTranscript) {
      state = state.copyWith(currentTranscript: event.text);
    } else if (event is VoiceCallEnded) {
      state = state.copyWith(status: VoiceCallStatus.ended);
      _stopTimer();
      _eventsSubscription?.cancel();
    } else if (event is VoiceCallError) {
      state = state.copyWith(
        status: VoiceCallStatus.error,
        errorMessage: event.message,
      );
      _stopTimer();
      _eventsSubscription?.cancel();
    }
  }

  void resetToIdle() {
    _stopTimer();
    state = const VoiceCallState(); // Resets everything to idle state
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        callDuration: Duration(seconds: timer.tick),
      );
    });
  }

  void _stopTimer() {
    _durationTimer?.cancel();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _stopTimer();
    if (_voiceService.isCallActive) {
      _voiceService.endCall();
    }
    super.dispose();
  }
}

final voiceCallProvider = StateNotifierProvider<VoiceCallNotifier, VoiceCallState>((ref) {
  final service = ref.watch(voiceServiceProvider);
  return VoiceCallNotifier(service);
});
