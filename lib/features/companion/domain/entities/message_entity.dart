// Companion feature entities — placeholders

class MessageEntity {
  final String id;
  final String conversationId;
  final String content;
  final MessageRole role;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    required this.createdAt,
  });
}

enum MessageRole { user, companion }

class ConversationEntity {
  final String id;
  final String userId;
  final List<MessageEntity> messages;
  final DateTime lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.userId,
    required this.messages,
    required this.lastMessageAt,
  });
}
