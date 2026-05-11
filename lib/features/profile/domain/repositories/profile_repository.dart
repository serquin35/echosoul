import 'dart:io';
import '../entities/profile_entity.dart';

/// Contrato de dominio para operaciones de perfil.
abstract class ProfileRepository {
  /// Carga el perfil completo del usuario autenticado.
  Future<ProfileEntity> getProfile();

  /// Actualiza los campos de texto del perfil (nombre, companion, contacto).
  Future<void> updateProfile(ProfileEntity profile);

  /// Sube una foto de avatar al Storage y devuelve la URL pública.
  Future<String> uploadAvatar(File imageFile);

  /// Elimina el avatar actual del Storage.
  Future<void> deleteAvatar();

  /// Elimina la cuenta del usuario permanentemente.
  Future<void> deleteAccount();
}
