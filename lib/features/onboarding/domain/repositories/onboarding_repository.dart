import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OnboardingRepository {
  Future<void> completeOnboarding({
    required String displayName,
    required String companionName,
    String? crisisContactName,
    String? crisisContactPhone,
  });
}
