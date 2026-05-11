import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/env.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session == null || session.user == null) return null;
      return _mapSupabaseUserToEntity(session.user!);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUserToEntity(user);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // NOTE: For a real mobile build, configuring Google Sign-in requires
      // the google_sign_in package with proper OAuth client IDs for iOS/Android.
      // We will fallback to Supabase OAuth web-flow if native isn't setup.
      final String? envRedirect = Env.authRedirectUrl;
      final String redirectTo = envRedirect ?? (kIsWeb ? '${Uri.base.origin}/' : 'echosoul://login-callback/');
      final success = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );

      if (!success) {
        throw const AuthException('Fallo al iniciar sesión con Google.');
      }

      // In OAuth web flow, the user isn't immediately returned here.
      // The authStateChanges stream will catch the successful login after deep-link redirect.
      // For this abstraction, we just return a temporary placeholder or await the session.
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        return _mapSupabaseUserToEntity(user);
      } else {
        // Will be populated later via deep link
        return const UserEntity(id: '', email: '');
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw const AuthException('Credenciales inválidas.');
      return _mapSupabaseUserToEntity(response.user!);
    } catch (e) {
      final err = e.toString();
      if (err.contains('Invalid login credentials')) {
        throw const AuthException('Correo o contraseña incorrectos.');
      } else if (err.contains('Email not confirmed')) {
        throw const AuthException('Por favor confirma tu correo electrónico antes de iniciar sesión.');
      }
      throw AuthException('Error al iniciar sesión: $err');
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) throw const AuthException('Error al crear la cuenta.');
      return _mapSupabaseUserToEntity(response.user!);
    } catch (e) {
      final err = e.toString();
      if (err.contains('User already registered')) {
        throw const AuthException('Este correo ya está registrado.');
      } else if (err.contains('Password should be at least')) {
        throw const AuthException('La contraseña debe tener al menos 6 caracteres.');
      }
      throw AuthException('Error al crear la cuenta: $err');
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    try {
      // On web, we redirect to the origin and let main.dart's listener handle the routing
      // once the recovery event is detected. On mobile, we use the custom scheme.
      final String base = Env.authRedirectUrl ?? (kIsWeb ? Uri.base.origin : 'echosoul://');
      final String redirectTo = base.endsWith('/') ? '${base}reset-password' : '$base/reset-password';
      
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } catch (e) {
      final err = e.toString();
      throw AuthException('Error al enviar el enlace de recuperación: $err');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      final err = e.toString();
      throw AuthException('Error al actualizar la contraseña: $err');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // Typically needs a secure Edge Function or specific setup for user self-deletion.
      // This is a placeholder for the actual Supabase admin/RPC call.
      throw const AuthException('Eliminar cuenta no está implementado aún.');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  UserEntity _mapSupabaseUserToEntity(User supabaseUser) {
    return UserEntity(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['full_name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      onboardingCompleted: supabaseUser.userMetadata?['onboarding_completed'] as bool? ?? false,
    );
  }
}
