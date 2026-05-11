import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../data/repositories/onboarding_repository_impl.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(Supabase.instance.client);
});

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return OnboardingController(repository);
});

class OnboardingController extends StateNotifier<AsyncValue<void>> {
  final OnboardingRepository _repository;

  OnboardingController(this._repository) : super(const AsyncData(null));

  Future<void> completeOnboarding({
    required String displayName,
    required String companionName,
    String? crisisContactName,
    String? crisisContactPhone,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.completeOnboarding(
        displayName: displayName,
        companionName: companionName,
        crisisContactName: crisisContactName,
        crisisContactPhone: crisisContactPhone,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
