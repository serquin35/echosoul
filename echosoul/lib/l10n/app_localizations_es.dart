// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'EchoSoul';

  @override
  String get tagline => 'Nunca más sol@.';

  @override
  String get loginEmailBtn => 'Ingresar con Correo';

  @override
  String get loginGoogleBtn => 'Continuar con Google';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get languageSheetTitle => 'Idioma de la app';

  @override
  String get errorLoadingProfile => 'Error al cargar perfil';

  @override
  String get retry => 'Reintentar';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get yourInformation => 'Tu información';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get nameHint => 'Como quieres que te llamemos';

  @override
  String get emailLabel => 'Correo';

  @override
  String get yourCompanion => 'Tu Companion';

  @override
  String get companionNameLabel => 'Nombre del Companion';

  @override
  String get companionNameHint => 'Ej: Echo, Luna, Kai…';

  @override
  String get pauseCompanion => 'Pausar compañero';

  @override
  String get pauseCompanionSubtitle =>
      'Silencia temporalmente notificaciones y check-ins proactivos';

  @override
  String get languageSectionTitle => 'Idioma';

  @override
  String get appLanguageLabel => 'Idioma de la app';

  @override
  String get emergencyContactSection => 'Contacto de emergencia';

  @override
  String get emergencyContactSubtitle =>
      'EchoSoul te lo recordará si lo necesitas';

  @override
  String get contactNameLabel => 'Nombre del contacto';

  @override
  String get notConfigured => 'No configurado';

  @override
  String get contactNameHint => 'Nombre de alguien de confianza';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get emergencyPhoneTitle => 'Teléfono de emergencia';

  @override
  String get phoneHint => '+34 600 000 000';

  @override
  String get legalInfoSection => 'Información Legal';

  @override
  String get legalNoticesLabel => 'Avisos Legales y Ética';

  @override
  String get legalNoticesSubtitle => 'Términos, Privacidad y Compromiso IA';

  @override
  String get planSection => 'Plan';

  @override
  String get planStatusLabel => 'Estado del plan';

  @override
  String get loading => 'Cargando...';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Gratuito';

  @override
  String get messagesToday => 'Mensajes hoy';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get exportDataLabel => 'Exportar mis datos (GDPR)';

  @override
  String get deleteAccountLabel => 'Eliminar cuenta';

  @override
  String get signOutConfirmMessage => '¿Seguro que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exitSignOut => 'Salir';

  @override
  String get deleteAccountConfirmMessage =>
      'Esta acción es irreversible. Todos tus datos serán eliminados permanentemente.';

  @override
  String get deleteBtn => 'Eliminar';

  @override
  String errorDeletingAccount(String e) {
    return 'Error al eliminar cuenta: $e';
  }

  @override
  String get preparingDataFile => 'Preparando tu archivo de datos...';

  @override
  String get downloadStarted => 'Descarga del archivo de datos iniciada.';

  @override
  String get exportedDataSubject => 'Mis datos exportados de EchoSoul';

  @override
  String errorExportingData(String e) {
    return 'Error al exportar datos: $e';
  }

  @override
  String get photoUpdatedSuccessfully => 'Foto actualizada correctamente.';

  @override
  String errorUploadingPhoto(String e) {
    return 'Error al subir la foto: $e';
  }

  @override
  String get loginSuccessMessage => 'Sesión iniciada correctamente';

  @override
  String get signupSuccessMessage => 'Cuenta creada con éxito';

  @override
  String get joinUs => 'Únete a nosotros.';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get emailRequired => 'Por favor ingresa tu correo';

  @override
  String get emailInvalid => 'Ingresa un correo válido';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get passwordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get createAccountBtn => 'Crear Cuenta';

  @override
  String get noAccountRegister => '¿No tienes cuenta? Regístrate';

  @override
  String get haveAccountLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get orSeparator => 'O';

  @override
  String get termsPrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get andText => ' y ';

  @override
  String get privacyPolicy => 'Políticas de Privacidad';

  @override
  String get period => '.';

  @override
  String get recoverPasswordTitle => 'Recuperar contraseña';

  @override
  String get recoverPasswordSubtitle =>
      'Ingresa tu correo para recibir un enlace de recuperación.';

  @override
  String get validEmailRequired => 'Ingresa un correo válido.';

  @override
  String get recoveryLinkSent => 'Enlace de recuperación enviado.';

  @override
  String get sendBtn => 'Enviar';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get onlineVoiceCall => 'En línea • Llamada de voz';

  @override
  String get mood => 'Ánimo';

  @override
  String get moodState => 'Estado de ánimo';

  @override
  String get voiceMemoryMore => 'Voz, memoria ilimitada y más';

  @override
  String get howAreYouFeeling => '¿Cómo te sientes hoy?';

  @override
  String get alwaysHereToListen => 'Siempre aquí para escucharte';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get moodStateSplit => 'Estado de\nÁnimo';

  @override
  String get crisisDisclaimer =>
      'No estás solo. Si sientes que estás en peligro o necesitas hablar con alguien, por favor utiliza estos recursos gratuitos y confidenciales las 24 horas:';

  @override
  String get suicidePreventionLine => 'Prevención Suicidio (024)';

  @override
  String get online => 'En línea';

  @override
  String get companionInfo => 'Info del compañero';

  @override
  String get startConversation => 'Comienza la conversación';

  @override
  String get companionHereToListen => 'Tu compañero está aquí para escucharte.';

  @override
  String get dailyLimitReached =>
      'Has alcanzado el límite diario de mensajes gratuitos.';

  @override
  String get empathicCompanion => 'Compañero Empático · EchoSoul';

  @override
  String get memoryCapability =>
      'Recuerda tus sueños, miedos y pasiones para ofrecerte un acompañamiento con contexto y profundidad real.';

  @override
  String get proactiveCapability =>
      'Buenos días personalizados, recordatorios y llamadas de voz para acompañarte en tu rutina diaria.';

  @override
  String get privacyCapability =>
      'Tus conversaciones están protegidas con cifrado extremo a extremo. Nunca se venderán ni compartirán.';

  @override
  String get ethicalDisclaimer =>
      'No ofrece diagnósticos ni sustituye la terapia. ';

  @override
  String get legalEthicalNotices => 'Avisos Legales y Éticos';

  @override
  String get noResponseTryAgain => 'No recibí respuesta. Intenta de nuevo.';

  @override
  String get didNotUnderstandRepeat => 'No entendí eso. ¿Puedes repetirlo?';

  @override
  String get connectionTimeoutCheckInternet =>
      'La conexión tardó demasiado. Comprueba tu internet.';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado.';

  @override
  String helloUser(String displayName) {
    return 'Hola, $displayName';
  }

  @override
  String get voiceCallSplit => 'Llamada\nde Voz';

  @override
  String get startChatBtn => 'Iniciar Chat';

  @override
  String get traveler => 'Viajero';

  @override
  String get defaultCompanionName => 'Echo';

  @override
  String get waitingForResponse => 'Esperando respuesta...';

  @override
  String get typeAMessage => 'Escribe un mensaje…';

  @override
  String get capabilitiesLabel => 'Capacidades';

  @override
  String get emotionalSupportTitle => 'Apoyo Emocional 24/7';

  @override
  String get emotionalSupportDesc =>
      'Siempre disponible, libre de juicios y enfocado en tu bienestar. Un espacio para expresarte sin filtros.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navChat => 'Chat';

  @override
  String get navMood => 'Estado de ánimo';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navLegal => 'Legal';

  @override
  String get legalEthicalCommitment => 'Nuestro Compromiso Ético';

  @override
  String get legalHowWeUseAI => 'Cómo usamos la Inteligencia Artificial';

  @override
  String get legalCompanionNotTherapy => 'Acompañamiento, no Terapia';

  @override
  String get legalCompanionNotTherapyDesc =>
      'EchoSoul es un acompañante virtual diseñado para reducir la soledad. No sustituye el diagnóstico o tratamiento de un profesional de la salud mental.';

  @override
  String get legalTransparency => 'Transparencia';

  @override
  String get legalTransparencyDesc =>
      'Todas tus interacciones son generadas por modelos de IA. No estás hablando con un humano real.';

  @override
  String get legalPreventDependency => 'Prevención de Dependencia';

  @override
  String get legalPreventDependencyDesc =>
      'Fomentamos el uso responsable. EchoSoul te recordará la importancia de tus conexiones humanas reales.';

  @override
  String get legalOfficialDocs => 'Documentación Oficial';

  @override
  String get legalTermsConditions => 'Términos y Condiciones';

  @override
  String get legalPrivacyPolicy => 'Política de Privacidad';

  @override
  String get legalCookiePolicy => 'Política de Cookies';

  @override
  String get legalInCaseOfCrisis => 'En caso de crisis';

  @override
  String get legalImmediateHelp => 'Ayuda Inmediata (España)';

  @override
  String get legalImmediateHelpDesc =>
      'Si sientes que estás en peligro, tienes pensamientos de hacerte daño o necesitas soporte emocional inmediato en España, por favor recurre a los siguientes recursos oficiales, públicos y gratuitos disponibles las 24 horas del día.';

  @override
  String get legalCallEmergencies => 'Llamar a Emergencias (112)';

  @override
  String get legalSuicidePrevention => 'Línea de Prevención del Suicidio (024)';

  @override
  String get legalHopeLine => 'Teléfono de la Esperanza (717 003 717)';

  @override
  String get moodSaveSuccess => 'Estado de ánimo guardado correctamente';

  @override
  String get moodVeryBad => 'Muy mal';

  @override
  String get moodBad => 'Mal';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodGood => 'Bien';

  @override
  String get moodVeryGood => 'Muy bien';

  @override
  String get moodAddNoteHint =>
      'Añade una nota sobre cómo te sientes (opcional)...';

  @override
  String get moodSaveStateBtn => 'Guardar estado';

  @override
  String get moodNoHistory => 'Aún no has registrado ningún estado.';

  @override
  String get moodRecentHistory => 'Historial reciente';

  @override
  String get moodNoLabel => 'Sin etiqueta';

  @override
  String get becomePremium => 'Hazte Premium';

  @override
  String get premiumSubtitle => 'Voz, memoria ilimitada y más';

  @override
  String get dailyLimitSection => 'Límite diario de mensajes';

  @override
  String get dailyLimitSubtitle =>
      'Para evitar dependencia, puedes establecer un máximo de mensajes por día';

  @override
  String get dailyLimitCustom => 'Límite personalizado';

  @override
  String get dailyLimitPlan => 'Límite del plan';

  @override
  String get dailyLimitUnlimited => 'Ilimitado';

  @override
  String get dailyLimitDialogTitle => 'Ajustar límite diario';

  @override
  String get dailyLimitDialogHint => 'Mensajes por día (0 = sin límite)';

  @override
  String get dailyLimitSaved => 'Límite diario actualizado';

  @override
  String get dailyLimitResetDaily => 'Se reinicia cada día';

  @override
  String get dailyLimitMin => 'Mín. 5 mensajes';

  @override
  String dailyLimitMax(int max) {
    return 'Máx. $max mensajes';
  }

  @override
  String get save => 'Guardar';

  @override
  String get usePlanLimit => 'Usar límite del plan';

  @override
  String get paywallTitle => 'Libera a tu Companion';

  @override
  String get paywallSubtitle =>
      'Conversa sin barreras con el asistente de IA empática que te comprende.';

  @override
  String get paywallCancelSubtitle =>
      'Cancela en cualquier momento desde tu perfil.';

  @override
  String get paywallLimitlessMessages => 'Mensajes Diarios Ilimitados';

  @override
  String get paywallLimitlessMessagesSub => 'Sin restricción de límite diario';

  @override
  String get paywallLongTermMemory => 'Memoria a Largo Plazo';

  @override
  String get paywallLongTermMemorySub =>
      'Tu Companion recordará cada conversación';

  @override
  String get paywallProactiveInteractions => 'Interacciones Proactivas';

  @override
  String get paywallProactiveInteractionsSub =>
      'Buenos días, insights semanales y más';

  @override
  String get paywallVoiceCalls => 'Llamadas de Voz (Próximamente)';

  @override
  String get paywallVoiceCallsSub => 'Acceso anticipado cuando esté disponible';

  @override
  String get paywallStartSubscription => 'Iniciar Suscripción';

  @override
  String get paywallWebSubscriptionTitle => 'Suscripción desde la Web';

  @override
  String get paywallWebSubscriptionDesc =>
      'Para cumplir con las políticas de Google Play Store, las suscripciones premium se gestionan exclusivamente a través de nuestra web.\n\nPor favor, visita echosoul.dev en tu navegador para activar tu plan premium.';

  @override
  String get paywallAlreadyPremium => '¡Ya eres Premium!';
}
