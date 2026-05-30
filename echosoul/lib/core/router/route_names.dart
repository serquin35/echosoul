/// Named route constants for GoRouter.
/// Always use these — never hardcode path strings.
abstract class RouteNames {
  static const splash       = '/';
  static const login        = '/login';
  static const onboarding   = '/onboarding';
  static const companionHome = '/home';
  static const chat         = 'chat';        // sub-route of /home
  static const voiceCall    = 'voice';       // sub-route of /home
  static const mood         = '/mood';
  static const profile      = '/profile';
  static const companionSettings = '/profile/companion';
  static const legal        = '/legal';
  static const resetPassword = '/reset-password';
  static const paywall       = '/paywall';
}
