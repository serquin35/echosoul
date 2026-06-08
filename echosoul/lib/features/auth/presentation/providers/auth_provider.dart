import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
});

final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authEventsProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref ref;
  
  AuthController(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }
  
  Future<void> _init() async {
    state = await AsyncValue.guard(() async {
      return await ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      return ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      return ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
          );
      return ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<void> resetPasswordForEmail(String email) async {
    await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updatePassword(newPassword);
      return ref.read(authRepositoryProvider).getCurrentUser();
    });
  }

  Future<void> updateFcmToken(String token) async {
    await ref.read(authRepositoryProvider).updateFcmToken(token);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  return AuthController(ref);
});
