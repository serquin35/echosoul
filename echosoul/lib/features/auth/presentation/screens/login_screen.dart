import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/design_system/atoms/es_button.dart';
import '../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  
  bool _isLoginMode = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushNamed(RouteNames.legal);
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushNamed(RouteNames.legal);
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (_isLoginMode) {
      ref.read(authControllerProvider.notifier).signInWithEmail(email, password);
    } else {
      ref.read(authControllerProvider.notifier).signUpWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Listen for auth errors or successful logins
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceAll('AuthException: ', '')),
            backgroundColor: EsColors.distress,
          ),
        );
      } else if (next is AsyncData && next.value != null && previous?.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLoginMode ? S.of(context).loginSuccessMessage : S.of(context).signupSuccessMessage),
            backgroundColor: EsColors.success,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EsSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom - 
                      (EsSpacing.xl * 2), // Subtracting padding
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'EchoSoul',
                        style: EsTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: EsSpacing.sm),
                      Text(
                        _isLoginMode ? S.of(context).tagline : S.of(context).joinUs,
                        style: EsTypography.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: EsSpacing.xxl),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: S.of(context).emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).emailRequired;
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return S.of(context).emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: EsSpacing.md),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: S.of(context).passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).passwordRequired;
                          }
                          if (!_isLoginMode && value.length < 6) {
                            return S.of(context).passwordMinLength;
                          }
                          return null;
                        },
                      ),
                      if (_isLoginMode) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog();
                            },
                            child: Text(
                              S.of(context).forgotPassword,
                              style: EsTypography.caption.copyWith(
                                color: EsColors.neonCyan,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: EsSpacing.xl),
                      ],
                      EsButton(
                        label: _isLoginMode ? S.of(context).loginEmailBtn : S.of(context).createAccountBtn,
                        isLoading: isLoading,
                        onPressed: _submitForm,
                      ),
                      const SizedBox(height: EsSpacing.md),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _formKey.currentState?.reset();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                        child: Text(
                          _isLoginMode 
                              ? S.of(context).noAccountRegister 
                              : S.of(context).haveAccountLogin,
                          style: EsTypography.bodyMedium.copyWith(
                            color: EsColors.textSecondaryDark,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: EsSpacing.lg),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: EsSpacing.md),
                            child: Text(S.of(context).orSeparator, style: EsTypography.caption),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: EsSpacing.lg),
                      EsButton(
                        label: S.of(context).loginGoogleBtn,
                        isLoading: isLoading,
                        variant: EsButtonVariant.secondary,
                        leadingIcon: Icons.g_mobiledata,
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).signInWithGoogle();
                        },
                      ),
                      const SizedBox(height: EsSpacing.lg),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: EsTypography.caption.copyWith(
                            color: EsColors.textSecondaryDark,
                          ),
                          children: [
                            TextSpan(text: S.of(context).termsPrefix),
                            TextSpan(
                              text: S.of(context).termsOfService,
                              style: const TextStyle(
                                color: EsColors.neonCyan,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _termsRecognizer,
                            ),
                            TextSpan(text: S.of(context).andText),
                            TextSpan(
                              text: S.of(context).privacyPolicy,
                              style: const TextStyle(
                                color: EsColors.neonCyan,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _privacyRecognizer,
                            ),
                            TextSpan(text: S.of(context).period),
                          ],
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: EsSpacing.xxl),
                        TextButton(
                          onPressed: () {
                            // This simulates the navigation that should happen when Supabase detects a recovery link
                            context.go(RouteNames.resetPassword);
                          },
                          child: const Text(
                            '[DEBUG] Simular Navegación a ResetPassword',
                            style: TextStyle(color: Colors.white24, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: EsColors.surfaceDark,
          title: Text(S.of(context).recoverPasswordTitle, style: EsTypography.headlineMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).recoverPasswordSubtitle, style: EsTypography.bodyMedium),
              const SizedBox(height: EsSpacing.md),
              TextFormField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  hintText: S.of(context).emailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel, style: const TextStyle(color: EsColors.textSecondaryDark)),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).validEmailRequired), backgroundColor: EsColors.distress),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await ref.read(authControllerProvider.notifier).resetPasswordForEmail(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).recoveryLinkSent), backgroundColor: EsColors.success),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('AuthException: ', '')), backgroundColor: EsColors.distress),
                    );
                  }
                }
              },
              child: Text(S.of(context).sendBtn, style: const TextStyle(color: EsColors.neonCyan)),
            ),
          ],
        );
      },
    );
  }
}
