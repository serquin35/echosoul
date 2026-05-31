import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/es_colors.dart';
import '../../../../core/constants/es_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/es_platform.dart';
import '../../../../shared/design_system/atoms/es_interactive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Master layout shell. Renders:
/// - [_WebSidebar] + content on web / wide screens
/// - [_MobileBottomNav] + content on native builds
class MainLayoutScreen extends ConsumerWidget {
  final Widget child;
  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Responsive breakpoint: also use sidebar on wide tablets / desktop browsers
    final width = MediaQuery.sizeOf(context).width;
    final useSidebar = width >= EsPlatform.sidebarBreakpoint;

    if (useSidebar) {
      return _WebLayout(child: child);
    }
    return _MobileLayout(child: child);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEB LAYOUT — Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _WebLayout extends ConsumerWidget {
  final Widget child;
  const _WebLayout({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: Row(
        children: [
          _EsSidebar(),
          // Thin separator line
          Container(width: 1, color: EsColors.divider.withOpacity(0.4)),
          // Main content expands with max width constraint for desktop
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT — Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith(RouteNames.mood)) return 1;
    if (path.startsWith(RouteNames.profile)) return 2;
    if (path.startsWith(RouteNames.legal)) return 3;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.companionHome);
      case 1:
        context.goNamed(RouteNames.mood);
      case 2:
        context.goNamed(RouteNames.profile);
      case 3:
        context.goNamed(RouteNames.legal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);
    return Scaffold(
      backgroundColor: EsColors.backgroundDark,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: EsColors.surfaceElevated.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: EsColors.surfaceDark,
          selectedItemColor: EsColors.primaryBlue,
          unselectedItemColor: EsColors.textSecondaryDark,
          currentIndex: index,
          onTap: (i) => _onTap(i, context),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: S.of(context).navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.mood_outlined),
              activeIcon: const Icon(Icons.mood),
              label: S.of(context).navMood,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: S.of(context).navProfile,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shield_outlined),
              activeIcon: const Icon(Icons.shield),
              label: S.of(context).navLegal,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEB SIDEBAR WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _EsSidebar extends ConsumerWidget {
  _EsSidebar();

  static const _width = 240.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;

    return SizedBox(
      width: _width,
      child: Container(
        color: EsColors.surfaceDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo / Brand ──────────────────────────────
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'EchoSoul',
                    style: EsTypography.headlineMedium.copyWith(
                      color: EsColors.textPrimaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Nav Items ─────────────────────────────────
            _SidebarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: S.of(context).navHome,
              isActive: path.startsWith(RouteNames.companionHome) &&
                  !path.startsWith('${RouteNames.companionHome}/chat'),
              onTap: () => context.goNamed(RouteNames.companionHome),
            ),
            _SidebarItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: S.of(context).navChat,
              isActive: path.contains('/chat'),
              onTap: () => context.goNamed(RouteNames.chat),
            ),
            _SidebarItem(
              icon: Icons.mood_outlined,
              activeIcon: Icons.mood,
              label: S.of(context).navMood,
              isActive: path.startsWith(RouteNames.mood),
              onTap: () => context.goNamed(RouteNames.mood),
            ),
            _SidebarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: S.of(context).navProfile,
              isActive: path.startsWith(RouteNames.profile),
              onTap: () => context.goNamed(RouteNames.profile),
            ),
            _SidebarItem(
              icon: Icons.gavel_outlined,
              activeIcon: Icons.gavel,
              label: S.of(context).navLegal,
              isActive: path.startsWith(RouteNames.legal),
              onTap: () => context.goNamed(RouteNames.legal),
            ),

            const Spacer(),

            // ── Upgrade Banner ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: EsInteractive(
                onTap: () => context.push(RouteNames.paywall),
                hoverScale: 1.02,
                child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EsColors.primaryBlue.withOpacity(0.15),
                      EsColors.neonCyan.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: EsColors.primaryBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: EsColors.neonCyan, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).becomePremium,
                      style: EsTypography.bodyMedium.copyWith(
                        color: EsColors.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).premiumSubtitle,
                      style: EsTypography.bodySmall.copyWith(
                        color: EsColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

            // ── User Avatar + Signout ─────────────────────
            const Divider(color: EsColors.divider, height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: EsColors.surfaceElevated,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person,
                            color: EsColors.textSecondaryDark, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user?.displayName ?? S.of(context).traveler,
                      style: EsTypography.bodySmall.copyWith(
                        color: EsColors.textSecondaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Sign-out icon
                  IconButton(
                    icon: const Icon(Icons.logout,
                        color: EsColors.textSecondaryDark, size: 18),
                    tooltip: S.of(context).signOut,
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signOut();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? EsColors.primaryBlue.withOpacity(0.15)
                : _hovering
                    ? EsColors.surfaceElevated.withOpacity(0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(
                    color: EsColors.primaryBlue.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              // Active indicator bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: active ? EsColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                active ? widget.activeIcon : widget.icon,
                color: active ? EsColors.primaryBlue : EsColors.textSecondaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: EsTypography.bodyMedium.copyWith(
                  color: active
                      ? EsColors.primaryBlue
                      : EsColors.textSecondaryDark,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
