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

    return BillingEntity(
      plan: data['plan'] as String? ?? 'free',
      dailyLimit: data['daily_limit'] as int? ?? 20,
      messagesUsed: data['messages_used'] as int? ?? 0,
      lastResetDate: lastReset,
    );
  }

  @override
  Future<void> incrementMessagesUsed() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.rpc('increment_messages_used', params: {
      'p_user_id': user.id,
    });
  }
}
