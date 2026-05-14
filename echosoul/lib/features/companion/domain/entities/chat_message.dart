/// Represents a single chat message.
class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isError;
  final bool isCrisis;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.isError = false,
    this.isCrisis = false,
  });

  /// Creates a user message (right side of chat).
  factory ChatMessage.fromUser(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isFromUser: true,
        timestamp: DateTime.now(),
      );

  /// Creates a companion message (left side of chat).
  factory ChatMessage.fromCompanion(String text, {bool isCrisis = false}) => ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        text: text,
        isFromUser: false,
        timestamp: DateTime.now(),
        isCrisis: isCrisis,
      );

  /// Creates an error message shown in the companion bubble.
  factory ChatMessage.error(String message) => ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        text: message,
        isFromUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
}
