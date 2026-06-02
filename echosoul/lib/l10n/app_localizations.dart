import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'EchoSoul'**
  String get appTitle;

  /// Tagline shown on login screen
  ///
  /// In es, this message translates to:
  /// **'Nunca más sol@.'**
  String get tagline;

  /// No description provided for @loginEmailBtn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con Correo'**
  String get loginEmailBtn;

  /// No description provided for @loginGoogleBtn.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginGoogleBtn;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @languageSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get languageSheetTitle;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar perfil'**
  String get errorLoadingProfile;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @yourInformation.
  ///
  /// In es, this message translates to:
  /// **'Tu información'**
  String get yourInformation;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @yourName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In es, this message translates to:
  /// **'Como quieres que te llamemos'**
  String get nameHint;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get emailLabel;

  /// No description provided for @yourCompanion.
  ///
  /// In es, this message translates to:
  /// **'Tu Companion'**
  String get yourCompanion;

  /// No description provided for @companionNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Companion'**
  String get companionNameLabel;

  /// No description provided for @companionNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Echo, Luna, Kai…'**
  String get companionNameHint;

  /// No description provided for @pauseCompanion.
  ///
  /// In es, this message translates to:
  /// **'Pausar compañero'**
  String get pauseCompanion;

  /// No description provided for @pauseCompanionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Silencia temporalmente notificaciones y check-ins proactivos'**
  String get pauseCompanionSubtitle;

  /// No description provided for @languageSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageSectionTitle;

  /// No description provided for @appLanguageLabel.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get appLanguageLabel;

  /// No description provided for @emergencyContactSection.
  ///
  /// In es, this message translates to:
  /// **'Contacto de emergencia'**
  String get emergencyContactSection;

  /// No description provided for @emergencyContactSubtitle.
  ///
  /// In es, this message translates to:
  /// **'EchoSoul te lo recordará si lo necesitas'**
  String get emergencyContactSubtitle;

  /// No description provided for @contactNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del contacto'**
  String get contactNameLabel;

  /// No description provided for @notConfigured.
  ///
  /// In es, this message translates to:
  /// **'No configurado'**
  String get notConfigured;

  /// No description provided for @contactNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de alguien de confianza'**
  String get contactNameHint;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phoneLabel;

  /// No description provided for @emergencyPhoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de emergencia'**
  String get emergencyPhoneTitle;

  /// No description provided for @phoneHint.
  ///
  /// In es, this message translates to:
  /// **'+34 600 000 000'**
  String get phoneHint;

  /// No description provided for @legalInfoSection.
  ///
  /// In es, this message translates to:
  /// **'Información Legal'**
  String get legalInfoSection;

  /// No description provided for @legalNoticesLabel.
  ///
  /// In es, this message translates to:
  /// **'Avisos Legales y Ética'**
  String get legalNoticesLabel;

  /// No description provided for @legalNoticesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Términos, Privacidad y Compromiso IA'**
  String get legalNoticesSubtitle;

  /// No description provided for @planSection.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get planSection;

  /// No description provided for @planStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado del plan'**
  String get planStatusLabel;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @premium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In es, this message translates to:
  /// **'Gratuito'**
  String get free;

  /// No description provided for @messagesToday.
  ///
  /// In es, this message translates to:
  /// **'Mensajes hoy'**
  String get messagesToday;

  /// No description provided for @upgradeToPremium.
  ///
  /// In es, this message translates to:
  /// **'Actualizar a Premium'**
  String get upgradeToPremium;

  /// No description provided for @accountSection.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get accountSection;

  /// No description provided for @exportDataLabel.
  ///
  /// In es, this message translates to:
  /// **'Exportar mis datos (GDPR)'**
  String get exportDataLabel;

  /// No description provided for @deleteAccountLabel.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountLabel;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar sesión?'**
  String get signOutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @exitSignOut.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exitSignOut;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible. Todos tus datos serán eliminados permanentemente.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @deleteBtn.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteBtn;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar cuenta: {e}'**
  String errorDeletingAccount(String e);

  /// No description provided for @preparingDataFile.
  ///
  /// In es, this message translates to:
  /// **'Preparando tu archivo de datos...'**
  String get preparingDataFile;

  /// No description provided for @downloadStarted.
  ///
  /// In es, this message translates to:
  /// **'Descarga del archivo de datos iniciada.'**
  String get downloadStarted;

  /// No description provided for @exportedDataSubject.
  ///
  /// In es, this message translates to:
  /// **'Mis datos exportados de EchoSoul'**
  String get exportedDataSubject;

  /// No description provided for @errorExportingData.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar datos: {e}'**
  String errorExportingData(String e);

  /// No description provided for @photoUpdatedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Foto actualizada correctamente.'**
  String get photoUpdatedSuccessfully;

  /// No description provided for @errorUploadingPhoto.
  ///
  /// In es, this message translates to:
  /// **'Error al subir la foto: {e}'**
  String errorUploadingPhoto(String e);

  /// No description provided for @loginSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada correctamente'**
  String get loginSuccessMessage;

  /// No description provided for @signupSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada con éxito'**
  String get signupSuccessMessage;

  /// No description provided for @joinUs.
  ///
  /// In es, this message translates to:
  /// **'Únete a nosotros.'**
  String get joinUs;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu correo'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get emailInvalid;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @createAccountBtn.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get createAccountBtn;

  /// No description provided for @noAccountRegister.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? Regístrate'**
  String get noAccountRegister;

  /// No description provided for @haveAccountLogin.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? Inicia sesión'**
  String get haveAccountLogin;

  /// No description provided for @orSeparator.
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get orSeparator;

  /// No description provided for @termsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al continuar, aceptas nuestros '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get termsOfService;

  /// No description provided for @andText.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get andText;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Políticas de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @period.
  ///
  /// In es, this message translates to:
  /// **'.'**
  String get period;

  /// No description provided for @recoverPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get recoverPasswordTitle;

  /// No description provided for @recoverPasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo para recibir un enlace de recuperación.'**
  String get recoverPasswordSubtitle;

  /// No description provided for @validEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get validEmailRequired;

  /// No description provided for @recoveryLinkSent.
  ///
  /// In es, this message translates to:
  /// **'Enlace de recuperación enviado.'**
  String get recoveryLinkSent;

  /// No description provided for @sendBtn.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendBtn;

  /// No description provided for @connectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get connectionError;

  /// No description provided for @onlineVoiceCall.
  ///
  /// In es, this message translates to:
  /// **'En línea • Llamada de voz'**
  String get onlineVoiceCall;

  /// No description provided for @mood.
  ///
  /// In es, this message translates to:
  /// **'Ánimo'**
  String get mood;

  /// No description provided for @moodState.
  ///
  /// In es, this message translates to:
  /// **'Estado de ánimo'**
  String get moodState;

  /// No description provided for @voiceMemoryMore.
  ///
  /// In es, this message translates to:
  /// **'Voz, memoria ilimitada y más'**
  String get voiceMemoryMore;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te sientes hoy?'**
  String get howAreYouFeeling;

  /// No description provided for @alwaysHereToListen.
  ///
  /// In es, this message translates to:
  /// **'Siempre aquí para escucharte'**
  String get alwaysHereToListen;

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones Rápidas'**
  String get quickActions;

  /// No description provided for @moodStateSplit.
  ///
  /// In es, this message translates to:
  /// **'Estado de\nÁnimo'**
  String get moodStateSplit;

  /// No description provided for @crisisDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'No estás solo. Si sientes que estás en peligro o necesitas hablar con alguien, por favor utiliza estos recursos gratuitos y confidenciales las 24 horas:'**
  String get crisisDisclaimer;

  /// No description provided for @suicidePreventionLine.
  ///
  /// In es, this message translates to:
  /// **'Prevención Suicidio (024)'**
  String get suicidePreventionLine;

  /// No description provided for @online.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get online;

  /// No description provided for @companionInfo.
  ///
  /// In es, this message translates to:
  /// **'Info del compañero'**
  String get companionInfo;

  /// No description provided for @startConversation.
  ///
  /// In es, this message translates to:
  /// **'Comienza la conversación'**
  String get startConversation;

  /// No description provided for @companionHereToListen.
  ///
  /// In es, this message translates to:
  /// **'Tu compañero está aquí para escucharte.'**
  String get companionHereToListen;

  /// No description provided for @dailyLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el límite diario de mensajes gratuitos.'**
  String get dailyLimitReached;

  /// No description provided for @empathicCompanion.
  ///
  /// In es, this message translates to:
  /// **'Compañero Empático · EchoSoul'**
  String get empathicCompanion;

  /// No description provided for @memoryCapability.
  ///
  /// In es, this message translates to:
  /// **'Recuerda tus sueños, miedos y pasiones para ofrecerte un acompañamiento con contexto y profundidad real.'**
  String get memoryCapability;

  /// No description provided for @proactiveCapability.
  ///
  /// In es, this message translates to:
  /// **'Buenos días personalizados, recordatorios y llamadas de voz para acompañarte en tu rutina diaria.'**
  String get proactiveCapability;

  /// No description provided for @privacyCapability.
  ///
  /// In es, this message translates to:
  /// **'Tus conversaciones están protegidas con cifrado extremo a extremo. Nunca se venderán ni compartirán.'**
  String get privacyCapability;

  /// No description provided for @ethicalDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'No ofrece diagnósticos ni sustituye la terapia. '**
  String get ethicalDisclaimer;

  /// No description provided for @legalEthicalNotices.
  ///
  /// In es, this message translates to:
  /// **'Avisos Legales y Éticos'**
  String get legalEthicalNotices;

  /// No description provided for @noResponseTryAgain.
  ///
  /// In es, this message translates to:
  /// **'No recibí respuesta. Intenta de nuevo.'**
  String get noResponseTryAgain;

  /// No description provided for @didNotUnderstandRepeat.
  ///
  /// In es, this message translates to:
  /// **'No entendí eso. ¿Puedes repetirlo?'**
  String get didNotUnderstandRepeat;

  /// No description provided for @connectionTimeoutCheckInternet.
  ///
  /// In es, this message translates to:
  /// **'La conexión tardó demasiado. Comprueba tu internet.'**
  String get connectionTimeoutCheckInternet;

  /// No description provided for @unexpectedError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado.'**
  String get unexpectedError;

  /// No description provided for @helloUser.
  ///
  /// In es, this message translates to:
  /// **'Hola, {displayName}'**
  String helloUser(String displayName);

  /// No description provided for @voiceCallSplit.
  ///
  /// In es, this message translates to:
  /// **'Llamada\nde Voz'**
  String get voiceCallSplit;

  /// No description provided for @startChatBtn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Chat'**
  String get startChatBtn;

  /// No description provided for @traveler.
  ///
  /// In es, this message translates to:
  /// **'Viajero'**
  String get traveler;

  /// No description provided for @defaultCompanionName.
  ///
  /// In es, this message translates to:
  /// **'Echo'**
  String get defaultCompanionName;

  /// No description provided for @waitingForResponse.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta...'**
  String get waitingForResponse;

  /// No description provided for @typeAMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje…'**
  String get typeAMessage;

  /// No description provided for @capabilitiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidades'**
  String get capabilitiesLabel;

  /// No description provided for @emotionalSupportTitle.
  ///
  /// In es, this message translates to:
  /// **'Apoyo Emocional 24/7'**
  String get emotionalSupportTitle;

  /// No description provided for @emotionalSupportDesc.
  ///
  /// In es, this message translates to:
  /// **'Siempre disponible, libre de juicios y enfocado en tu bienestar. Un espacio para expresarte sin filtros.'**
  String get emotionalSupportDesc;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navMood.
  ///
  /// In es, this message translates to:
  /// **'Estado de ánimo'**
  String get navMood;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navLegal.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get navLegal;

  /// No description provided for @legalEthicalCommitment.
  ///
  /// In es, this message translates to:
  /// **'Nuestro Compromiso Ético'**
  String get legalEthicalCommitment;

  /// No description provided for @legalHowWeUseAI.
  ///
  /// In es, this message translates to:
  /// **'Cómo usamos la Inteligencia Artificial'**
  String get legalHowWeUseAI;

  /// No description provided for @legalCompanionNotTherapy.
  ///
  /// In es, this message translates to:
  /// **'Acompañamiento, no Terapia'**
  String get legalCompanionNotTherapy;

  /// No description provided for @legalCompanionNotTherapyDesc.
  ///
  /// In es, this message translates to:
  /// **'EchoSoul es un acompañante virtual diseñado para reducir la soledad. No sustituye el diagnóstico o tratamiento de un profesional de la salud mental.'**
  String get legalCompanionNotTherapyDesc;

  /// No description provided for @legalTransparency.
  ///
  /// In es, this message translates to:
  /// **'Transparencia'**
  String get legalTransparency;

  /// No description provided for @legalTransparencyDesc.
  ///
  /// In es, this message translates to:
  /// **'Todas tus interacciones son generadas por modelos de IA. No estás hablando con un humano real.'**
  String get legalTransparencyDesc;

  /// No description provided for @legalPreventDependency.
  ///
  /// In es, this message translates to:
  /// **'Prevención de Dependencia'**
  String get legalPreventDependency;

  /// No description provided for @legalPreventDependencyDesc.
  ///
  /// In es, this message translates to:
  /// **'Fomentamos el uso responsable. EchoSoul te recordará la importancia de tus conexiones humanas reales.'**
  String get legalPreventDependencyDesc;

  /// No description provided for @legalOfficialDocs.
  ///
  /// In es, this message translates to:
  /// **'Documentación Oficial'**
  String get legalOfficialDocs;

  /// No description provided for @legalTermsConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get legalTermsConditions;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalCookiePolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Cookies'**
  String get legalCookiePolicy;

  /// No description provided for @legalInCaseOfCrisis.
  ///
  /// In es, this message translates to:
  /// **'En caso de crisis'**
  String get legalInCaseOfCrisis;

  /// No description provided for @legalImmediateHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda Inmediata (España)'**
  String get legalImmediateHelp;

  /// No description provided for @legalImmediateHelpDesc.
  ///
  /// In es, this message translates to:
  /// **'Si sientes que estás en peligro, tienes pensamientos de hacerte daño o necesitas soporte emocional inmediato en España, por favor recurre a los siguientes recursos oficiales, públicos y gratuitos disponibles las 24 horas del día.'**
  String get legalImmediateHelpDesc;

  /// No description provided for @legalCallEmergencies.
  ///
  /// In es, this message translates to:
  /// **'Llamar a Emergencias (112)'**
  String get legalCallEmergencies;

  /// No description provided for @legalSuicidePrevention.
  ///
  /// In es, this message translates to:
  /// **'Línea de Prevención del Suicidio (024)'**
  String get legalSuicidePrevention;

  /// No description provided for @legalHopeLine.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de la Esperanza (717 003 717)'**
  String get legalHopeLine;

  /// No description provided for @moodSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Estado de ánimo guardado correctamente'**
  String get moodSaveSuccess;

  /// No description provided for @moodVeryBad.
  ///
  /// In es, this message translates to:
  /// **'Muy mal'**
  String get moodVeryBad;

  /// No description provided for @moodBad.
  ///
  /// In es, this message translates to:
  /// **'Mal'**
  String get moodBad;

  /// No description provided for @moodNeutral.
  ///
  /// In es, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodGood.
  ///
  /// In es, this message translates to:
  /// **'Bien'**
  String get moodGood;

  /// No description provided for @moodVeryGood.
  ///
  /// In es, this message translates to:
  /// **'Muy bien'**
  String get moodVeryGood;

  /// No description provided for @moodAddNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Añade una nota sobre cómo te sientes (opcional)...'**
  String get moodAddNoteHint;

  /// No description provided for @moodSaveStateBtn.
  ///
  /// In es, this message translates to:
  /// **'Guardar estado'**
  String get moodSaveStateBtn;

  /// No description provided for @moodNoHistory.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado ningún estado.'**
  String get moodNoHistory;

  /// No description provided for @moodRecentHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial reciente'**
  String get moodRecentHistory;

  /// No description provided for @moodNoLabel.
  ///
  /// In es, this message translates to:
  /// **'Sin etiqueta'**
  String get moodNoLabel;

  /// No description provided for @becomePremium.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium'**
  String get becomePremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Voz, memoria ilimitada y más'**
  String get premiumSubtitle;

  /// No description provided for @dailyLimitSection.
  ///
  /// In es, this message translates to:
  /// **'Límite diario de mensajes'**
  String get dailyLimitSection;

  /// No description provided for @dailyLimitSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para evitar dependencia, puedes establecer un máximo de mensajes por día'**
  String get dailyLimitSubtitle;

  /// No description provided for @dailyLimitCustom.
  ///
  /// In es, this message translates to:
  /// **'Límite personalizado'**
  String get dailyLimitCustom;

  /// No description provided for @dailyLimitPlan.
  ///
  /// In es, this message translates to:
  /// **'Límite del plan'**
  String get dailyLimitPlan;

  /// No description provided for @dailyLimitUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Ilimitado'**
  String get dailyLimitUnlimited;

  /// No description provided for @dailyLimitDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustar límite diario'**
  String get dailyLimitDialogTitle;

  /// No description provided for @dailyLimitDialogHint.
  ///
  /// In es, this message translates to:
  /// **'Mensajes por día (0 = sin límite)'**
  String get dailyLimitDialogHint;

  /// No description provided for @dailyLimitSaved.
  ///
  /// In es, this message translates to:
  /// **'Límite diario actualizado'**
  String get dailyLimitSaved;

  /// No description provided for @dailyLimitResetDaily.
  ///
  /// In es, this message translates to:
  /// **'Se reinicia cada día'**
  String get dailyLimitResetDaily;

  /// No description provided for @dailyLimitMin.
  ///
  /// In es, this message translates to:
  /// **'Mín. 5 mensajes'**
  String get dailyLimitMin;

  /// No description provided for @dailyLimitMax.
  ///
  /// In es, this message translates to:
  /// **'Máx. {max} mensajes'**
  String dailyLimitMax(int max);

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @usePlanLimit.
  ///
  /// In es, this message translates to:
  /// **'Usar límite del plan'**
  String get usePlanLimit;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
