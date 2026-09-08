import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/animated_eco_hero_mark.dart';
import '../../shared/widgets/eco_vectors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Eco status stage definition
// ─────────────────────────────────────────────────────────────────────────────
class _EcoStageData {
  final String label;
  final IconData icon;
  final double activationT; // 0.0–1.0 into main animation

  const _EcoStageData({
    required this.label,
    required this.icon,
    required this.activationT,
  });
}

const _stages = [
  _EcoStageData(
    label: 'Collecting',
    icon: Icons.electrical_services_rounded,
    activationT: 0.0,
  ),
  _EcoStageData(
    label: 'Recycling',
    icon: Icons.recycling_rounded,
    activationT: 0.38,
  ),
  _EcoStageData(label: 'Growing', icon: Icons.eco_rounded, activationT: 0.60),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main Splash Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Choreographed Splash Screen — 3200 ms eco-story animation:
/// E-WASTE → COLLECTION → RECYCLING → GREEN FUTURE
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // ── Per-element animations (all driven by single controller) ─────────────
  late Animation<double> _heroFade;
  late Animation<double> _heroScale;

  late Animation<Offset> _illustrationSlide;
  late Animation<double> _illustrationFade;

  // Staggered text — 4 separate elements
  late Animation<double> _appNameFade;
  late Animation<Offset> _appNameSlide;

  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  late Animation<double> _footerFade;

  // Eco status chips
  late Animation<double> _statusFade;

  Timer? _navTimer;

  // ── Internal stage tracking ───────────────────────────────────────────────
  int _currentStage = 0;

  @override
  void initState() {
    super.initState();

    // Total story: 3200ms
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 1. Hero fade in (t 0.00–0.14)
    _heroFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
    );
    _heroScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Illustration entrance (t 0.55–0.75)
    _illustrationSlide =
        Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _illustrationFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
    );

    // 3. App name "Kabadiwala" + "Connect" (t 0.62–0.80)
    _appNameFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.62, 0.80, curve: Curves.easeOut),
    );
    _appNameSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.62, 0.80, curve: Curves.easeOutCubic),
          ),
        );

    // 4. Tagline (t 0.70–0.86)
    _taglineFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.70, 0.86, curve: Curves.easeOut),
    );
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.70, 0.86, curve: Curves.easeOutCubic),
          ),
        );

    // 5. Mission footer (t 0.78–0.92)
    _footerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.78, 0.92, curve: Curves.easeOut),
    );

    // 6. Status indicator row (t 0.02–0.18 — appears early)
    _statusFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.02, 0.18, curve: Curves.easeOut),
    );

    // Track eco stage changes
    _ctrl.addListener(_onAnimationTick);

    _ctrl.forward();

    // Navigate at 3.2s (or earlier if initialization finishes and user taps)
    _navTimer = Timer(const Duration(milliseconds: 3200), _goToNextScreen);
  }

  void _onAnimationTick() {
    final t = _ctrl.value;
    int stage = 0;
    for (int i = _stages.length - 1; i >= 0; i--) {
      if (t >= _stages[i].activationT) {
        stage = i;
        break;
      }
    }
    if (stage != _currentStage) {
      setState(() => _currentStage = stage);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.maybeOf(context);
    if (mq != null && (mq.disableAnimations || mq.accessibleNavigation)) {
      // Reduced motion: jump to final state immediately
      _ctrl.value = 1.0;
    }
  }

  void _goToNextScreen() {
    if (!mounted) return;
    _navTimer?.cancel();

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    if (lang.isInitialized) {
      _navigate(lang.hasSelectedLanguage);
    } else {
      lang.ensureInitialized().then((_) {
        if (!mounted) return;
        _navigate(lang.hasSelectedLanguage);
      });
    }
  }

  void _navigate(bool hasSelected) {
    Navigator.of(
      context,
    ).pushReplacementNamed(hasSelected ? AppRoutes.home : AppRoutes.language);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ctrl.removeListener(_onAnimationTick);
    _ctrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToNextScreen,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppDimens.xxl),

              // ── 1. Central Hero ─────────────────────────────────────────
              FadeTransition(
                opacity: _heroFade,
                child: ScaleTransition(
                  scale: _heroScale,
                  child: AnimatedEcoHeroMark(
                    animation: _ctrl,
                    size: 132,
                    isDark: isDark,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.lg),

              // ── 2. Staggered Brand Text ──────────────────────────────────
              // App Name
              FadeTransition(
                opacity: _appNameFade,
                child: SlideTransition(
                  position: _appNameSlide,
                  child: _AppNameStack(isDark: isDark, lang: langProvider),
                ),
              ),

              const SizedBox(height: AppDimens.xs),

              // Tagline
              FadeTransition(
                opacity: _taglineFade,
                child: SlideTransition(
                  position: _taglineSlide,
                  child: Text(
                    langProvider.tr('tagline'),
                    style: AppTypography.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF86EFAC)
                          : AppColors.primaryGreenLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Spacer(),

              // ── 3. Collector Illustration (existing, enhanced entrance) ──
              FadeTransition(
                opacity: _illustrationFade,
                child: SlideTransition(
                  position: _illustrationSlide,
                  child: _IllustrationWrapper(
                    animation: _ctrl,
                    width: screenW * 0.88,
                    height: 248,
                    isDark: isDark,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.md),

              // ── 4. Mission footer ────────────────────────────────────────
              FadeTransition(
                opacity: _footerFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
                  child: Text(
                    langProvider.tr('splashFooter'),
                    style: AppTypography.bodyMedium(
                      isDark,
                    ).copyWith(fontStyle: FontStyle.italic, letterSpacing: 0.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.xl),

              // ── 5. Eco Status Indicator (replaces progress bar) ──────────
              FadeTransition(
                opacity: _statusFade,
                child: _EcoStatusRow(
                  animation: _ctrl,
                  currentStage: _currentStage,
                  isDark: isDark,
                ),
              ),

              const SizedBox(height: AppDimens.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Name Stack: "Kabadiwala" + "CONNECT" in accent lime
// ─────────────────────────────────────────────────────────────────────────────
class _AppNameStack extends StatelessWidget {
  final bool isDark;
  final LanguageProvider lang;

  const _AppNameStack({required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          lang.tr('appName'),
          style: AppTypography.headlineLarge(isDark)
              .copyWith(fontSize: 28, letterSpacing: -0.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustration wrapper with subtle parallax idle breathing
// ─────────────────────────────────────────────────────────────────────────────
class _IllustrationWrapper extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;
  final bool isDark;

  const _IllustrationWrapper({
    required this.animation,
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Subtle breathing after t=0.75: very tiny vertical oscillation
        final breathT = animation.value > 0.75
            ? (animation.value - 0.75) / 0.25 * math.pi * 2.5
            : 0.0;
        final breathOffset = math.sin(breathT) * 1.8;

        return Transform.translate(
          offset: Offset(0, breathOffset),
          child: child,
        );
      },
      child: CollectorIllustration(
        width: width,
        height: height,
        isDark: isDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Eco Status Row — replaces the old LinearProgressIndicator
// Three stages: COLLECTING → RECYCLING → GROWING
// ─────────────────────────────────────────────────────────────────────────────
class _EcoStatusRow extends StatelessWidget {
  final Animation<double> animation;
  final int currentStage;
  final bool isDark;

  const _EcoStatusRow({
    required this.animation,
    required this.currentStage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _stages.length; i++) ...[
              _StageChip(
                data: _stages[i],
                isActive: i == currentStage,
                isComplete:
                    t >= _stages[i].activationT &&
                    i < _stages.length - 1 &&
                    t >= _stages[i + 1].activationT,
                isDark: isDark,
                animValue: t,
              ),
              if (i < _stages.length - 1)
                _StageConnector(
                  isDark: isDark,
                  filled: t >= _stages[i + 1].activationT,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _StageChip extends StatelessWidget {
  final _EcoStageData data;
  final bool isActive;
  final bool isComplete;
  final bool isDark;
  final double animValue;

  const _StageChip({
    required this.data,
    required this.isActive,
    required this.isComplete,
    required this.isDark,
    required this.animValue,
  });

  @override
  Widget build(BuildContext context) {
    final greenPrimary = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final surfaceColor = isDark
        ? const Color(0xFF14231B)
        : const Color(0xFFDCFCE7);
    final textColor = isDark
        ? const Color(0xFF86EFAC)
        : AppColors.primaryGreenLight;
    final inactiveText = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final borderColor = isActive
        ? greenPrimary
        : isComplete
        ? greenPrimary.withValues(alpha: 0.5)
        : (isDark ? const Color(0xFF1F382B) : const Color(0xFFBBF7D0));

    // Active icon pulses gently
    final iconOpacity = isActive
        ? (0.7 + 0.3 * math.sin(animValue * math.pi * 8)).clamp(0.0, 1.0)
        : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isActive || isComplete) ? surfaceColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: iconOpacity,
            child: Icon(
              isComplete ? Icons.check_circle_rounded : data.icon,
              size: 14,
              color: (isActive || isComplete) ? greenPrimary : inactiveText,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: (isActive || isComplete) ? textColor : inactiveText,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageConnector extends StatelessWidget {
  final bool isDark;
  final bool filled;

  const _StageConnector({required this.isDark, required this.filled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 18,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: filled
          ? (isDark ? AppColors.primaryGreenDark : AppColors.primaryGreenLight)
                .withValues(alpha: 0.5)
          : (isDark ? const Color(0xFF1F382B) : const Color(0xFFBBF7D0)),
    );
  }
}
