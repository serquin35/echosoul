class BillingEntity {
  final String plan;
  final int dailyLimit;
  final int messagesUsed;
  final DateTime? lastResetDate;
  final int? customDailyLimit;

  const BillingEntity({
    this.plan = 'free',
    this.dailyLimit = 20,
    this.messagesUsed = 0,
    this.lastResetDate,
    this.customDailyLimit,
  });

  bool get isPremium => plan == 'premium';
  bool get isFree => plan == 'free';
  int get remainingMessages => dailyLimit - messagesUsed;
  bool get canSendMessage => isPremium || remainingMessages > 0;
  bool get hasCustomLimit => customDailyLimit != null && customDailyLimit! > 0;

  BillingEntity copyWith({
    String? plan,
    int? dailyLimit,
    int? messagesUsed,
    DateTime? lastResetDate,
    int? customDailyLimit,
  }) {
    return BillingEntity(
      plan: plan ?? this.plan,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      messagesUsed: messagesUsed ?? this.messagesUsed,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      customDailyLimit: customDailyLimit ?? this.customDailyLimit,
    );
  }
}
