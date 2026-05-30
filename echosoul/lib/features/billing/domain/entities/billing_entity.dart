class BillingEntity {
  final String plan;
  final int dailyLimit;
  final int messagesUsed;
  final DateTime? lastResetDate;

  const BillingEntity({
    this.plan = 'free',
    this.dailyLimit = 20,
    this.messagesUsed = 0,
    this.lastResetDate,
  });

  bool get isPremium => plan == 'premium';
  bool get isFree => plan == 'free';
  int get remainingMessages => dailyLimit - messagesUsed;
  bool get canSendMessage => isPremium || remainingMessages > 0;

  BillingEntity copyWith({
    String? plan,
    int? dailyLimit,
    int? messagesUsed,
    DateTime? lastResetDate,
  }) {
    return BillingEntity(
      plan: plan ?? this.plan,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      messagesUsed: messagesUsed ?? this.messagesUsed,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}
