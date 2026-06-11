import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vapi/vapi.dart';
import '../../../../automation/interfaces/voice_service.dart';
import '../../domain/entities/voice_call_event.dart';
import '../../../../core/config/env.dart';

class VapiVoiceRepository implements VoiceService {
  final SupabaseClient _supabase;
  final VapiClient _vapiClient;
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  VapiCall? _currentCall;
  StreamSubscription? _callSubscription;
  
  final _eventController = StreamController<VoiceCallEvent>.broadcast();
  bool _isCallActive = false;
  String? _currentCallRecordId;

  VapiVoiceRepository(this._supabase) : _vapiClient = VapiClient(Env.validatedVapiPublicKey()) {
    _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _stopRingtone() {
    _ringtonePlayer.stop();
  }

  void _setupVapiListeners(VapiCall call) {
    _callSubscription?.cancel();
    _callSubscription = call.onEvent.listen((event) {
      if (event.label == "call-start") {
        _stopRingtone();
        _isCallActive = true;
        final callId = event.value?['callId'] as String?;
        if (callId != null && _currentCallRecordId != null) {
          _supabase.from('voice_calls').update({
            'vapi_call_id': callId,
            'status': 'active',
            'started_at': DateTime.now().toIso8601String(),
          }).eq('id', _currentCallRecordId!);
        }
        _eventController.add(const VoiceCallStarted());
      } else if (event.label == "call-end") {
        _isCallActive = false;
        _eventController.add(const VoiceCallEnded());
        _finalizeCallRecord();
      } else if (event.label == "message") {
        // Fallback: stop ringtone when any message is received (crucial for web where call-start might be delayed or skipped)
        _stopRingtone();
        
        final msg = event.value;
        if (msg is Map) {
          if (msg['type'] == "speech-update") {
            _eventController.add(VoiceCallSpeechUpdate(
              role: msg['role'] == 'assistant' ? 'assistant' : 'user',
              status: msg['status'] == 'started' ? 'started' : 'stopped',
            ));
          } else if (msg['type'] == "transcript") {
            _eventController.add(VoiceCallTranscript(
              role: msg['role'] == 'assistant' ? 'assistant' : 'user',
              text: msg['transcript'] ?? '',
              isFinal: msg['transcriptType'] == 'final',
            ));
          }
        }
      } else if (event.label == "call-error" || event.label == "error") {
        _stopRingtone();
        _eventController.add(VoiceCallError(message: event.value?.toString() ?? 'Unknown error'));
        _isCallActive = false;
        _finalizeCallRecord();
      }
    });
  }

  @override
  Stream<VoiceCallEvent> get callEvents => _eventController.stream;

  @override
  bool get isCallActive => _isCallActive;

  @override
  Future<void> startInAppCall({
    required String userId,
    required String companionName,
    required String userName,
    String? firstMessage,
  }) async {
    try {
      _eventController.add(const VoiceCallConnecting());
      
      // --- 1. Verificación de Límites de Llamada ---
      final planData = await _supabase
          .from('user_plans')
          .select('plan, daily_voice_calls_limit, max_call_duration_seconds')
          .eq('user_id', userId)
          .maybeSingle();

      final String currentPlan = planData?['plan'] ?? 'free';
      int? dailyLimit;
      int maxDurationSeconds = planData?['max_call_duration_seconds'] ?? 600; // 10 mins por defecto
      if (maxDurationSeconds > 43200) {
        maxDurationSeconds = 43200; // Vapi hard limit (12 hours)
      }

      if (currentPlan != 'premium') {
        dailyLimit = planData?['daily_voice_calls_limit'] ?? 5; // fallback razonable
      }
      
      if (dailyLimit != null) {
        final now = DateTime.now();
        final todayStart = DateTime.utc(now.year, now.month, now.day).toIso8601String();
        
        final callsToday = await _supabase
            .from('voice_calls')
            .select('id')
            .eq('user_id', userId)
            .gte('created_at', todayStart);
            
        if ((callsToday as List).length >= dailyLimit) {
          throw Exception('LIMIT_REACHED');
        }
      }
      // --- Fin Verificación ---

      // Start playing ringback tone immediately
      await _ringtonePlayer.play(AssetSource('audio/ringback.wav'));
      
      final response = await _supabase.from('voice_calls').insert({
        'user_id': userId,
        'call_type': 'on_demand',
        'status': 'initiated',
      }).select().single();
      
      _currentCallRecordId = response['id'];

      final call = await _vapiClient.start(
        assistantId: Env.validatedVapiAssistantId(),
        assistantOverrides: {
          "maxDurationSeconds": maxDurationSeconds,
          if (firstMessage != null) "firstMessage": firstMessage,
          "variableValues": {
            "companion_name": companionName,
            "user_name": userName,
          },
          "metadata": {
            "echosoul_user_id": userId,
            "echosoul_call_record_id": _currentCallRecordId,
          },
        },
      );
      
      _currentCall = call;
      _setupVapiListeners(call);
      
      if (_currentCallRecordId != null) {
        await _supabase.from('voice_calls').update({
          'status': 'ringing',
        }).eq('id', _currentCallRecordId!);
      }
    } catch (e) {
      _stopRingtone();
      _eventController.add(VoiceCallError(message: 'Failed to start call: $e'));
      _isCallActive = false;
    }
  }

  @override
  Future<void> endCall() async {
    try {
      _stopRingtone();
      if (_currentCall != null) {
        await _currentCall!.stop();
        _currentCall!.dispose();
        _currentCall = null;
      }
      _isCallActive = false;
      _eventController.add(const VoiceCallEnded());
      await _finalizeCallRecord();
    } catch (e) {
      _eventController.add(VoiceCallError(message: 'Failed to end call: $e'));
    }
  }

  Future<void> _finalizeCallRecord() async {
    if (_currentCallRecordId != null) {
      try {
        await _supabase.from('voice_calls').update({
          'status': 'completed',
          'ended_at': DateTime.now().toIso8601String(),
        }).eq('id', _currentCallRecordId!);
        _currentCallRecordId = null;
      } catch (e) {
        // Silent fail for logging
      }
    }
  }

  void dispose() {
    _stopRingtone();
    _ringtonePlayer.dispose();
    _callSubscription?.cancel();
    _currentCall?.dispose();
    _vapiClient.dispose();
    _eventController.close();
  }
}
