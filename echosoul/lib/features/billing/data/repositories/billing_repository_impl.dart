import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/billing_entity.dart';
import '../../domain/repositories/billing_repository.dart';

class BillingRepositoryImpl implements BillingRepository {
  final SupabaseClient _client;

  BillingRepositoryImpl(this._client);

  @override
  Future<BillingEntity> getPlan() async {
    final user = _client.auth.currentUser;
    if (user == null) return const BillingEntity();

    final data = await _client
        .from('user_plans')
        .select('plan, daily_limit, messages_used, last_reset_date')
        .eq('user_id', user.id)
        .maybeSingle() as Map<String, dynamic>?;

    if (data == null) return const BillingEntity();

    final lastReset = data['last_reset_date'] != null
        ? DateTime.tryParse(data['last_reset_date'] as String)
        : null;

    final today = DateTime.now();
    final needsReset = lastReset == null ||
        lastReset.year != today.year ||
        lastReset.month != today.month ||
        lastReset.day != today.day;

    if (needsReset && (data['plan'] as String?) == 'free') {
      await _client
          .from('user_plans')
          .update({'messages_used': 0, 'last_reset_date': today.toIso8601String().substring(0, 10)})
          .eq('user_id', user.id);

      return BillingEntity(
        plan: data['plan'] as String? ?? 'free',
        dailyLimit: data['daily_limit'] as int? ?? 20,
        messagesUsed: 0,
        lastResetDate: today,
      );
    }

    final planLimit = data['daily_limit'] as int? ?? 20;
    final customLimit = await _getCustomDailyLimit(user.id);
    final effectiveLimit = customLimit != null && customLimit > 0 && customLimit < planLimit
        ? customLimit
        : planLimit;

    return BillingEntity(
      plan: data['plan'] as String? ?? 'free',
      dailyLimit: effectiveLimit,
      messagesUsed: data['messages_used'] as int? ?? 0,
      lastResetDate: lastReset,
      customDailyLimit: customLimit,
    );
  }

  Future<int?> _getCustomDailyLimit(String userId) async {
    try {
      final prefs = await _client
          .from('user_preferences')
          .select('custom_daily_limit')
          .eq('user_id', userId)
          .maybeSingle() as Map<String, dynamic>?;
      return prefs?['custom_daily_limit'] as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setCustomDailyLimit(int limit) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('user_preferences').upsert({
      'user_id': user.id,
      'custom_daily_limit': limit > 0 ? limit : null,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> incrementMessagesUsed() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.rpc('increment_messages_used', params: {
        'p_user_id': user.id,
      });
    } catch (_) {
      try {
        final current = await _client
            .from('user_plans')
            .select('messages_used')
            .eq('user_id', user.id)
            .maybeSingle() as Map<String, dynamic>?;

        if (current != null) {
          final count = (current['messages_used'] as int? ?? 0) + 1;
          await _client
              .from('user_plans')
              .update({'messages_used': count, 'updated_at': DateTime.now().toUtc().toIso8601String()})
              .eq('user_id', user.id);
        } else {
          await _client.from('user_plans').insert({
            'user_id': user.id,
            'plan': 'free',
            'daily_limit': 20,
            'messages_used': 1,
            'last_reset_date': DateTime.now().toIso8601String().substring(0, 10),
          });
        }
      } catch (_) {}
    }
  }
}
