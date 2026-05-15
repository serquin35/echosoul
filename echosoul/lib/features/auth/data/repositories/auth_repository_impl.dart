import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/env.dart';
import '../../../../core/services/fcm_service.dart';
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
      if (kIsWeb) {
        return await _signInWithGoogleWeb();
      } else {
        return await _signInWithGoogleNative();
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserEntity> _signInWithGoogleWeb() async {
    final String? envRedirect = Env.authRedirectUrl;
    final String redirectTo = envRedirect ?? (kIsWeb ? '${Uri.base.origin}/' : 'echosoul://login-callback/');
    final success = await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );

    if (!success) {
      throw const AuthException('Fallo al iniciar sesión con Google.');
    }

    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      return _mapSupabaseUserToEntity(user);
    } else {
      return const UserEntity(id: '', email: '');
    }
  }

  Future<UserEntity> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: Env.googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw const AuthException('Inicio con Google cancelado.');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw const AuthException('No se pudo obtener el token de Google.');

    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );

    if (response.user == null) throw const AuthException('Error al autenticar con Supabase.');

    return _mapSupabaseUserToEntity(response.user!);
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
    String? displayName, // Added displayName
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'full_name': displayName} : null,
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
      final response = await _supabaseClient.functions.invoke('delete-account');
      if (response.status != 200) {
        throw AuthException('Error al eliminar cuenta: ${response.data}');
      }
      await signOut();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error de red al eliminar la cuenta: $e');
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabaseClient
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
          
      debugPrint('AuthRepository: FCM Token actualizado en Supabase');
    } catch (e) {
      debugPrint('AuthRepository: Error al actualizar FCM Token: $e');
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
