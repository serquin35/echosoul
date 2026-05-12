import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_typography.dart';
import '../providers/companion_data_provider.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isMuted = false;
  bool _isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companionNameAsync = ref.watch(companionNameProvider);
    final companionName = companionNameAsync.value ?? 'Echo';

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: Stack(
        children: [
          // ── Background Gradient & Blur ─────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    EsColors.primaryBlue.withOpacity(0.15),
                    EsColors.backgroundDark,
                    EsColors.deepBlue.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          
          // ── Main Content ──────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // Companion Identity & Pulse Animation
                    _PulseAvatar(
                      controller: _pulseController,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [EsColors.primaryBlue, EsColors.neonCyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: EsColors.primaryBlue.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.graphic_eq,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Text(
                      companionName,
                      style: EsTypography.displayMedium.copyWith(
                        color: EsColors.textPrimaryDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En línea • Llamada de voz',
                      style: EsTypography.bodyLarge.copyWith(
                        color: EsColors.neonCyan.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Simulated Voice Visualizer
                    const _VoiceVisualizer(),
                    
                    const Spacer(),
                    
                    // Call Controls
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            label: _isMuted ? 'Unmute' : 'Mute',
                            isActive: _isMuted,
                            onTap: () => setState(() => _isMuted = !_isMuted),
                          ),
                          _ControlButton(
                            icon: Icons.call_end,
                            label: 'Finalizar',
                            isEndCall: true,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          _ControlButton(
                            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                            label: 'Altavoz',
                            isActive: _isSpeakerOn,
                            onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back Button (Optional since we have end call, but good for UI)
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.expand_more, color: Colors.white60, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseAvatar extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _PulseAvatar({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse 1
            Transform.scale(
              scale: 1.0 + (controller.value * 0.5),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: EsColors.primaryBlue.withOpacity((1.0 - controller.value).clamp(0.0, 1.0)),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Outer pulse 2
            Transform.scale(
              scale: 1.0 + (((controller.value + 0.5) % 1.0) * 0.5),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: EsColors.neonCyan.withOpacity((1.0 - ((controller.value + 0.5) % 1.0)).clamp(0.0, 1.0)),
                    width: 1,
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isEndCall;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isEndCall = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isEndCall 
        ? EsColors.distress 
        : isActive 
            ? Colors.white.withOpacity(0.2) 
            : Colors.white.withOpacity(0.05);
            
    final iconColor = isEndCall 
        ? Colors.white 
        : isActive 
            ? EsColors.neonCyan 
            : Colors.white70;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isEndCall ? Colors.transparent : Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: isEndCall ? [
                BoxShadow(
                  color: EsColors.distress.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: EsTypography.bodySmall.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VoiceVisualizer extends StatelessWidget {
  const _VoiceVisualizer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(15, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.2, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 4,
                height: 10 + (30 * value * (index % 3 == 0 ? 0.8 : 0.5)),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: EsColors.neonCyan.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
