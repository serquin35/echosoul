import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/env.dart';
import '../../data/repositories/n8n_chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final _dioProvider = Provider<Dio>((ref) => Dio());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return N8nChatRepositoryImpl(
    dio: ref.watch(_dioProvider),
    webhookUrl: Env.n8nChatWebhookUrl,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Session ID — unique per user, stable for the whole session
// ─────────────────────────────────────────────────────────────────────────────

final chatSessionIdProvider = Provider<String>((ref) {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  final ts = DateTime.now().millisecondsSinceEpoch;
  return uid != null ? '${uid}_$ts' : 'anon_$ts';
});

// ─────────────────────────────────────────────────────────────────────────────
// Chat state
// ─────────────────────────────────────────────────────────────────────────────

/// The full list of messages + whether the companion is typing.
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
  });

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  /// Sends the user's [text] and appends both messages to the state.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage.fromUser(text.trim());
    // 1. Append user message + show typing indicator
    state = state.copyWith(
      messages: [userMsg, ...state.messages],
      isTyping: true,
    );

    // 2. Call repository
    final sessionId = ref.read(chatSessionIdProvider);
    final reply = await ref.read(chatRepositoryProvider).sendMessage(
          userMessage: text.trim(),
          sessionId: sessionId,
        );

    // 3. Append companion reply, hide typing indicator
    state = state.copyWith(
      messages: [reply, ...state.messages],
      isTyping: false,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
