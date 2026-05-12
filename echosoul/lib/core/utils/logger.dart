/// Safe logger for EchoSoul.
/// NEVER log user PII (names, messages, phone numbers, mood data).
class EsLogger {
  static const _tag = 'EchoSoul';

  static void info(String message) {
    // ignore: avoid_print
    print('[$_tag][INFO] $message');
  }

  static void warning(String message) {
    // ignore: avoid_print
    print('[$_tag][WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('[$_tag][ERROR] $message');
    if (error != null) print('  └─ $error');
    if (stackTrace != null) print('  └─ $stackTrace');
  }

  static void debug(String message) {
    assert(() {
      // ignore: avoid_print
      print('[$_tag][DEBUG] $message');
      return true;
    }());
  }
}
