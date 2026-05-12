import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../companion/presentation/providers/companion_data_provider.dart';

// ── Repositorio ──────────────────────────────────────────
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(Supabase.instance.client);
});

// ── Estados auxiliares ───────────────────────────────────
enum AvatarUploadStatus { idle, uploading, success, error }

// ── Notifier principal ───────────────────────────────────
class ProfileNotifier extends AsyncNotifier<ProfileEntity> {
  AvatarUploadStatus _avatarStatus = AvatarUploadStatus.idle;
  AvatarUploadStatus get avatarStatus => _avatarStatus;

  @override
  Future<ProfileEntity> build() async {
    return ref.read(profileRepositoryProvider).getProfile();
  }

  /// Actualiza un campo individual y sincroniza con Supabase.
  Future<void> updateField(ProfileEntity updated) async {
    final previous = state.value;
    // Optimistic update
    state = AsyncData(updated);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(updated);
      // Invalida el companionName que usa CompanionHomeScreen
      ref.invalidate(companionNameProvider);
    } catch (e, st) {
      // Rollback
      if (previous != null) state = AsyncData(previous);
      state = AsyncError(e, st);
    }
  }

  /// Sube una imagen de avatar y actualiza el estado.
  Future<void> uploadAvatar(File file) async {
    _avatarStatus = AvatarUploadStatus.uploading;
    final previous = state.value;
    try {
      final url = await ref.read(profileRepositoryProvider).uploadAvatar(file);
      if (previous != null) {
        state = AsyncData(previous.copyWith(avatarUrl: url));
      }
      _avatarStatus = AvatarUploadStatus.success;
    } catch (e) {
      _avatarStatus = AvatarUploadStatus.error;
      rethrow;
    }
  }

  /// Elimina el avatar y limpia la URL.
  Future<void> deleteAvatar() async {
    final previous = state.value;
    try {
      await ref.read(profileRepositoryProvider).deleteAvatar();
      if (previous != null) {
        state = AsyncData(previous.copyWith(clearAvatar: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cierra sesión.
  Future<void> signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
  }

  /// Elimina la cuenta permanentemente.
  Future<void> deleteAccount() async {
    await ref.read(profileRepositoryProvider).deleteAccount();
    // No necesitamos invalidar nada aquí ya que la sesión se cerrará
    // y el AppRouter redirigirá al Login.
  }
}

// Provider que expone el notifier
final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileEntity>(ProfileNotifier.new);

// companionNameProvider vive en companion_data_provider.dart
// Accesible vía el import de arriba (companion_data_provider.dart).

