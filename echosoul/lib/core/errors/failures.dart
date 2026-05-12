/// Base failure class. All domain-level errors extend this.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// ── Auth Failures ─────────────────────────────────────────
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure() : super('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.');
}

// ── Network Failures ──────────────────────────────────────
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet. Revisa tu red.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('La solicitud tardó demasiado. Intenta de nuevo.');
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor. Intenta más tarde.']);
}

// ── Data Failures ─────────────────────────────────────────
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder al almacenamiento local.']);
}

// ── Companion / LLM Failures ──────────────────────────────
class CompanionFailure extends Failure {
  const CompanionFailure([super.message = 'El companion no pudo responder. Intenta de nuevo.']);
}

class VoiceCallFailure extends Failure {
  const VoiceCallFailure([super.message = 'No se pudo iniciar la llamada de voz.']);
}

// ── Validation Failures ───────────────────────────────────
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ── Unknown ───────────────────────────────────────────────
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
