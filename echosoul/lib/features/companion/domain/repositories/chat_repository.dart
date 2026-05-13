import '../entities/chat_message.dart';

/// Contract for the chat repository.
/// The domain layer never knows HOW messages are sent — only that they can be.
abstract class ChatRepository {
  /// Sends [userMessage] and returns the companion's reply.
  Future<ChatMessage> sendMessage({
    required String userMessage,
    required String sessionId,
    required String userId,
  });
}
