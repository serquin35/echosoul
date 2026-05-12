import '../entities/user_entity.dart';

/// Contract for auth operations.
/// Implementations live in data/repositories/auth_repository_impl.dart
abstract class AuthRepository {
  /// Returns the current logged-in user, or null if not authenticated.
  Future<UserEntity?> getCurrentUser();

  /// Sign in with Google OAuth via Supabase.
  Future<UserEntity> signInWithGoogle();

  /// Sign in with email + password.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email + password.
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send password reset email.
  Future<void> resetPasswordForEmail(String email);

  /// Permanently delete the user account and all associated data.
  Future<void> deleteAccount();

  /// Update the password for the current user (used after recovery).
  Future<void> updatePassword(String newPassword);

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
