import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseClient _supabaseClient;

  OnboardingRepositoryImpl(this._supabaseClient);

  @override
  Future<void> completeOnboarding({
    required String displayName,
    required String companionName,
    String? crisisContactName,
    String? crisisContactPhone,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthException('Usuario no autenticado.');
      }

      // Update the user's profile
      await _supabaseClient.from('profiles').update({
        'display_name': displayName,
        'crisis_contact_name': crisisContactName,
        'crisis_contact_phone': crisisContactPhone,
        'onboarding_completed': true,
      }).eq('id', user.id);

      // Create or update the companion settings
      await _supabaseClient.from('companion_settings').upsert({
        'user_id': user.id,
        'companion_name': companionName,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Update auth metadata
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'onboarding_completed': true,
            'full_name': displayName,
          },
        ),
      );
    } catch (e) {
      throw AuthException('Error al guardar los datos de onboarding: ${e.toString()}');
    }
  }
}
