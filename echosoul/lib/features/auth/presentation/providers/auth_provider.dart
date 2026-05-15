import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(Supabase.instance.client);
}

@Riverpod(keepAlive: true)
Stream<UserEntity?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@Riverpod(keepAlive: true)
Stream<AuthState> authEvents(AuthEventsRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<UserEntity?> build() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
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
    // We don't change state to loading for this so we don't disrupt the UI flow of the main auth state.
    // Instead we just throw if there's an error and the UI can catch it.
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
