// TODO: Implement UserEntity
// This is a pure Dart class — no Flutter, no Supabase dependencies.

class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool onboardingCompleted;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.onboardingCompleted = false,
  });
}
