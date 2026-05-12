import 'package:flutter/foundation.dart';

/// Platform detection utility for EchoSoul.
///
/// Use this to conditionally enable/disable features per platform.
/// Never call kIsWeb directly in feature code — always use this abstraction.
abstract class EsPlatform {
  /// True when running in a browser (Flutter Web).
  static bool get isWeb => kIsWeb;

  /// True when running on a native mobile OS (Android / iOS).
  static bool get isMobile => !kIsWeb;

  /// Voice call feature requires a native audio stack.
  static bool get supportsVoiceCalls => !kIsWeb;

  /// FCM-based push notifications only work on native builds.
  static bool get supportsPushNotifications => !kIsWeb;

  /// Offline caching via Hive / SharedPreferences works on native.
  static bool get supportsOfflineMode => !kIsWeb;

  /// Wide sidebar layout is shown on web; bottom nav on mobile.
  static bool get useSidebarNavigation => kIsWeb;

  /// Minimum width (dp) at which we force sidebar even on web.
  static const double sidebarBreakpoint = 1024.0;
}
