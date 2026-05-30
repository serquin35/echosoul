import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<ProfileEntity> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    // Intenta obtener el perfil — si no existe, lo crea con valores por defecto
    var profileData = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle() as Map<String, dynamic>?;

    if (profileData == null) {
      // Crea la fila por defecto (el trigger debería haberlo hecho, esto es un fallback)
      final defaultName = user.userMetadata?['full_name'] as String?
          ?? user.email?.split('@').first
          ?? 'Viajero';
      await _client.from('profiles').upsert({
        'id': user.id,
        'display_name': defaultName,
        'onboarding_completed': false,
        'is_paused': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single() as Map<String, dynamic>;
    }

    final companion = await _client
        .from('companion_settings')
        .select('companion_name')
        .eq('user_id', user.id)
        .maybeSingle() as Map<String, dynamic>?;

    return ProfileEntity(
      id: user.id,
      email: user.email ?? '',
      displayName: profileData['display_name'] as String? ?? 'Viajero',
      avatarUrl: profileData['avatar_url'] as String?,
      companionName: companion?['companion_name'] as String? ?? 'Echo',
      crisisContactName: profileData['crisis_contact_name'] as String?,
      crisisContactPhone: profileData['crisis_contact_phone'] as String?,
      preferredLanguage: 'es',
      isPaused: profileData['is_paused'] as bool? ?? false,
    );
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    // Actualiza tablas en paralelo con tipo homogéneo Future<void>
    await Future.wait<void>([
      _client.from('profiles').update({
        'display_name': profile.displayName,
        'avatar_url': profile.avatarUrl,
        'crisis_contact_name': profile.crisisContactName,
        'crisis_contact_phone': profile.crisisContactPhone,
        'is_paused': profile.isPaused,
      }).eq('id', user.id).then((_) {}),
      _client.from('companion_settings').upsert({
        'user_id': user.id,
        'companion_name': profile.companionName,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).then((_) {}),
    ]);

    // Auth metadata aparte (devuelve UserResponse, no void)
    await _client.auth.updateUser(
      UserAttributes(data: {'full_name': profile.displayName}),
    );
  }


  @override
  Future<String> uploadAvatar(File imageFile) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    final fileExt = imageFile.path.split('.').last.toLowerCase();
    final filePath = '${user.id}/avatar.$fileExt';

    // Sube al bucket 'avatars' (upsert sobreescribe el anterior)
    await _client.storage.from('avatars').upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    // Genera URL pública
    final url = _client.storage.from('avatars').getPublicUrl(filePath);

    // Añade timestamp para invalidar cache del navegador/app
    final publicUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

    // Persiste en profiles
    await _client
        .from('profiles')
        .update({'avatar_url': publicUrl}).eq('id', user.id);

    return publicUrl;
  }

  @override
  Future<void> deleteAvatar() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    // Intentamos borrar los formatos más comunes
    try {
      await _client.storage
          .from('avatars')
          .remove(['${user.id}/avatar.jpg', '${user.id}/avatar.png', '${user.id}/avatar.jpeg']);
    } catch (_) {}

    await _client
        .from('profiles')
        .update({'avatar_url': null}).eq('id', user.id);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    final response = await _client.functions.invoke('delete-account');
    if (response.status != 200) {
      throw Exception('Error al eliminar cuenta: ${response.data}');
    }
    
    // Cerramos sesión localmente
    await _client.auth.signOut();
  }
}
