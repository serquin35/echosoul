import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/billing_entity.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../data/repositories/billing_repository_impl.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepositoryImpl(Supabase.instance.client);
});

final billingProvider = AsyncNotifierProvider<BillingNotifier, BillingEntity>(
  BillingNotifier.new,
);

class BillingNotifier extends AsyncNotifier<BillingEntity> {
  @override
  Future<BillingEntity> build() async {
    return ref.read(billingRepositoryProvider).getPlan();
  }

  Future<void> refresh() async {
    state = AsyncLoading();
    state = AsyncData(await ref.read(billingRepositoryProvider).getPlan());
  }

  Future<bool> trySendMessage() async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (current.isPremium) return true;
    if (current.canSendMessage) return true;
    return false;
  }

  Future<void> setCustomDailyLimit(int limit) async {
    await ref.read(billingRepositoryProvider).setCustomDailyLimit(limit);
    await refresh();
  }

  Future<void> incrementMessagesUsed() async {
    await ref.read(billingRepositoryProvider).incrementMessagesUsed();
    await refresh();
  }
}
