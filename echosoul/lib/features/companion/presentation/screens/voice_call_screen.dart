import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_typography.dart';
import '../providers/companion_data_provider.dart';
import '../providers/voice_call_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

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

  void _startCall(String companionName, String userName) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      ref.read(voiceCallProvider.notifier).startCall(userId, companionName, userName);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final companionNameAsync = ref.watch(companionNameProvider);
    final companionName = companionNameAsync.value ?? 'Echo';

    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName ?? S.of(context).traveler;

    final callState = ref.watch(voiceCallProvider);

    ref.listen(voiceCallProvider, (previous, next) {
      if (next.status == VoiceCallStatus.ended && previous?.status != VoiceCallStatus.ended) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            // Reiniciar el estado a idle para permitir una nueva llamada
            ref.read(voiceCallProvider.notifier).resetToIdle();
          }
        });
      }
    });

    String statusText = '';
    switch (callState.status) {
      case VoiceCallStatus.idle:
        statusText = 'Listo para llamar';
        break;
      case VoiceCallStatus.connecting:
        statusText = 'Conectando...';
        break;
      case VoiceCallStatus.active:
        statusText = _formatDuration(callState.callDuration);
        break;
      case VoiceCallStatus.ending:
        statusText = 'Finalizando...';
        break;
      case VoiceCallStatus.ended:
        statusText = 'Llamada finalizada';
        break;
      case VoiceCallStatus.error:
        statusText = 'Error';
        break;
    }

    final bool isIdle = callState.status == VoiceCallStatus.idle;
    final bool isActive = callState.status == VoiceCallStatus.active;
    final bool isConnecting = callState.status == VoiceCallStatus.connecting;
    final bool isError = callState.status == VoiceCallStatus.error;

    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: Stack(
        children: [
          // ── Background Gradient ─────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    EsColors.primaryBlue.withValues(alpha: 0.15),
                    EsColors.backgroundDark,
                    EsColors.deepBlue.withValues(alpha: 0.1),
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
                    
                    // Companion Avatar with pulse
                    _PulseAvatar(
                      controller: _pulseController,
                      isActive: isActive && callState.speakerRole == 'assistant',
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
                              color: EsColors.primaryBlue.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isIdle ? Icons.phone : Icons.graphic_eq,
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
                      statusText,
                      style: EsTypography.bodyLarge.copyWith(
                        color: isError
                            ? EsColors.distress 
                            : EsColors.neonCyan.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    if (isError && callState.errorMessage != null)
                      if (callState.errorMessage!.contains('LIMIT_REACHED'))
                        _buildPremiumUpsellCard(context)
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 24, right: 24),
                          child: Text(
                            callState.errorMessage!.replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: EsTypography.bodyMedium.copyWith(color: EsColors.distress),
                          ),
                        ),
                    
                    const Spacer(),
                    
                    // Voice Visualizer (only during active/connecting call)
                    if (isActive || isConnecting)
                      _VoiceVisualizer(isActive: callState.speakerRole == 'assistant'),
                    
                    const Spacer(),
                    
                    // ── Controls ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: _buildControls(callState, companionName, userName, isIdle, isError),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 20,
            left: 20,
            child: _ControlButton(
              icon: Icons.arrow_back,
              label: '',
              size: 48,
              onTap: () {
                if (isActive || isConnecting) {
                  ref.read(voiceCallProvider.notifier).endCall();
                }
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(VoiceCallState callState, String companionName, String userName, bool isIdle, bool isError) {
    // ── IDLE: Show big "Start Call" button ──
    if (isIdle) {
      return _StartCallButton(
        onTap: () => _startCall(companionName, userName),
      );
    }

    // ── ERROR: Show retry + go back ──
    if (isError) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.refresh,
            label: 'Reintentar',
            onTap: () => _startCall(companionName, userName),
          ),
          _ControlButton(
            icon: Icons.close,
            label: 'Volver',
            isEndCall: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    // ── IN-CALL: Show mute, end, speaker ──
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: callState.isMuted ? Icons.mic_off : Icons.mic,
          label: callState.isMuted ? 'Activar' : 'Silenciar',
          isActive: callState.isMuted,
          onTap: () {
            ref.read(voiceCallProvider.notifier).toggleMute();
          },
        ),
        _ControlButton(
          icon: Icons.call_end,
          label: 'Finalizar',
          isEndCall: true,
          onTap: () {
            if (callState.status != VoiceCallStatus.ending && 
                callState.status != VoiceCallStatus.ended) {
              ref.read(voiceCallProvider.notifier).endCall();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        _ControlButton(
          icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
          label: 'Altavoz',
          isActive: callState.isSpeakerOn,
          onTap: () {
            ref.read(voiceCallProvider.notifier).toggleSpeaker();
          },
        ),
      ],
    );
  }
}

  Widget _buildPremiumUpsellCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EsColors.deepBlue.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EsColors.neonCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: EsColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: EsColors.neonCyan, size: 48),
          const SizedBox(height: 16),
          Text(
            'Límite Diario Alcanzado',
            style: EsTypography.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Has superado tu límite de llamadas gratuitas por hoy. Hazte Premium para hablar sin límites.',
            textAlign: TextAlign.center,
            style: EsTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navegar al paywall
              Navigator.of(context).pop();
              // context.push('/paywall'); // TODO: Descomentar si usas go_router
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EsColors.neonCyan,
              foregroundColor: EsColors.backgroundDark,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text('Ver Planes Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

// ── Start Call Button ──────────────────────────────────
class _StartCallButton extends StatefulWidget {
  final VoidCallback onTap;
  const _StartCallButton({required this.onTap});

  @override
  State<_StartCallButton> createState() => _StartCallButtonState();
}

class _StartCallButtonState extends State<_StartCallButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [EsColors.neonCyan, EsColors.primaryBlue]
                  : [EsColors.primaryBlue, EsColors.neonCyan],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: EsColors.primaryBlue.withValues(alpha: _isHovered ? 0.6 : 0.3),
                blurRadius: _isHovered ? 25 : 15,
                spreadRadius: _isHovered ? 4 : 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Iniciar Llamada',
                style: EsTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulse Avatar ──────────────────────────────────
class _PulseAvatar extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final bool isActive;

  const _PulseAvatar({
    required this.controller, 
    required this.child,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return child;
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
                    color: EsColors.primaryBlue.withValues(alpha: (1.0 - controller.value).clamp(0.0, 1.0)),
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
                    color: EsColors.neonCyan.withValues(alpha: (1.0 - ((controller.value + 0.5) % 1.0)).clamp(0.0, 1.0)),
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

// ── Control Button (with hover + cursor for web) ──────────────────
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isEndCall;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isEndCall = false,
    this.size = 72,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isEndCall
        ? (_isHovered ? EsColors.distress.withValues(alpha: 0.9) : EsColors.distress)
        : widget.isActive
            ? (_isHovered ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.2))
            : (_isHovered ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05));
            
    final iconColor = widget.isEndCall
        ? Colors.white
        : widget.isActive
            ? EsColors.neonCyan
            : (_isHovered ? Colors.white : Colors.white70);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isEndCall ? Colors.transparent : Colors.white.withValues(alpha: _isHovered ? 0.25 : 0.1),
                  width: 1,
                ),
                boxShadow: [
                  if (widget.isEndCall)
                    BoxShadow(
                      color: EsColors.distress.withValues(alpha: _isHovered ? 0.5 : 0.3),
                      blurRadius: _isHovered ? 20 : 15,
                      spreadRadius: _isHovered ? 3 : 2,
                    ),
                  if (_isHovered && !widget.isEndCall)
                    BoxShadow(
                      color: EsColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(widget.icon, color: iconColor, size: widget.size * 0.4),
            ),
          ),
        ),
        if (widget.label.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.label,
            style: EsTypography.bodySmall.copyWith(
              color: _isHovered ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Voice Visualizer ──────────────────────────────────
class _VoiceVisualizer extends StatelessWidget {
  final bool isActive;
  const _VoiceVisualizer({this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(15, (index) {
          final targetHeight = isActive ? 1.0 : 0.2;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.2, end: targetHeight),
            duration: Duration(milliseconds: 400 + (index * 50)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 4,
                height: 10 + (30 * value * (index % 3 == 0 ? 0.8 : 0.5)),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: EsColors.neonCyan.withValues(alpha: 0.6),
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
