/// Entidad de dominio para el perfil completo del usuario.
/// Puro Dart — sin dependencias de Flutter ni Supabase.
class ProfileEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String companionName;
  final String? crisisContactName;
  final String? crisisContactPhone;
  final String preferredLanguage; // 'es' | 'en'
  final bool isPaused;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.companionName,
    this.crisisContactName,
    this.crisisContactPhone,
    this.preferredLanguage = 'es',
    this.isPaused = false,
  });

  ProfileEntity copyWith({
    String? displayName,
    String? avatarUrl,
    bool clearAvatar = false,
    String? companionName,
    String? crisisContactName,
    String? crisisContactPhone,
    String? preferredLanguage,
    bool? isPaused,
  }) {
    return ProfileEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      companionName: companionName ?? this.companionName,
      crisisContactName: crisisContactName ?? this.crisisContactName,
      crisisContactPhone: crisisContactPhone ?? this.crisisContactPhone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
