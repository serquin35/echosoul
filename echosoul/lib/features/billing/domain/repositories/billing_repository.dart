import '../entities/billing_entity.dart';

abstract class BillingRepository {
  Future<BillingEntity> getPlan();
  Future<void> setCustomDailyLimit(int limit);
  Future<void> incrementMessagesUsed();
}
