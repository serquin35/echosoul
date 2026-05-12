import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_spacing.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/design_system/atoms/es_button.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _companionNameController = TextEditingController(text: 'Echo');
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _userNameController.dispose();
    _companionNameController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _userNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa cómo quieres que te llame.'),
          backgroundColor: EsColors.distress,
        ),
      );
      return;
    }
    if (_currentPage == 1 && _companionNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre del companion no puede estar vacío.'),
          backgroundColor: EsColors.distress,
        ),
      );
      return;
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    try {
      await ref.read(onboardingControllerProvider.notifier).completeOnboarding(
            displayName: _userNameController.text.trim(),
            companionName: _companionNameController.text.trim(),
            crisisContactName: _contactNameController.text.trim(),
            crisisContactPhone: _contactPhoneController.text.trim(),
          );
      
      if (mounted) {
        context.goNamed(RouteNames.companionHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: EsColors.distress,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EsColors.primaryBlue.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EsColors.neonCyan.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: EsColors.textPrimaryDark),
                          onPressed: isLoading ? null : _previousPage,
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      Text(
                        'Paso ${_currentPage + 1} de 3',
                        style: EsTypography.caption.copyWith(color: EsColors.textSecondaryDark),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
                      minHeight: 6,
                      backgroundColor: EsColors.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(EsColors.primaryBlue),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),
                
                // Bottom Button Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: EsInteractive(
                    hoverScale: 1.02,
                    child: EsButton(
                      label: _currentPage == 2 ? 'Comenzar mi viaje' : 'Siguiente',
                      onPressed: isLoading ? null : _nextPage,
                      isLoading: isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _StepFadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a EchoSoul',
              style: EsTypography.headlineLarge.copyWith(color: EsColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para empezar a personalizar tu experiencia, ¿cómo te gustaría que te llamáramos?',
              style: EsTypography.bodyLarge,
            ),
            const SizedBox(height: 48),
            _CustomTextField(
              controller: _userNameController,
              label: 'Tu nombre o apodo',
              hint: 'Ej: Alex, Sam...',
              icon: Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _StepFadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Companion Personal',
              style: EsTypography.headlineLarge.copyWith(color: EsColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu compañero virtual te escuchará y te acompañará. ¿Qué nombre quieres ponerle?',
              style: EsTypography.bodyLarge,
            ),
            const SizedBox(height: 48),
            _CustomTextField(
              controller: _companionNameController,
              label: 'Nombre del Companion',
              hint: 'Echo, Luna, Kai...',
              icon: Icons.auto_awesome_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return _StepFadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacto de Confianza',
                style: EsTypography.headlineLarge.copyWith(color: EsColors.distress),
              ),
              const SizedBox(height: 16),
              const Text(
                'EchoSoul es tu compañero, pero en momentos de crisis real, es vital contar con alguien humano.\n\nEste paso es opcional, pero muy recomendado.',
                style: EsTypography.bodyLarge,
              ),
              const SizedBox(height: 40),
              _CustomTextField(
                controller: _contactNameController,
                label: 'Nombre (Opcional)',
                icon: Icons.favorite_border,
              ),
              const SizedBox(height: 24),
              _CustomTextField(
                controller: _contactPhoneController,
                label: 'Teléfono (Opcional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EsTypography.labelLarge.copyWith(color: EsColors.textSecondaryDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: EsTypography.bodyLarge,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: EsTypography.bodyMedium.copyWith(color: EsColors.textSecondaryDark.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: EsColors.primaryBlue, size: 20),
            filled: true,
            fillColor: EsColors.surfaceDark,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: EsColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepFadeIn extends StatelessWidget {
  final Widget child;
  const _StepFadeIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
