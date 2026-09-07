import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/eco_vectors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();

    // Automatically transition to Language Selection screen
    _navigationTimer = Timer(const Duration(milliseconds: 2600), () {
      _goToNextScreen();
    });
  }

  void _goToNextScreen() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    Navigator.of(context).pushReplacementNamed(AppRoutes.language);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToNextScreen,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.xxxl),
                  // 1. Stylized Recycling Leaf Logo
                  EcoRecycleLogo(size: 88, isDark: isDark),
                  const SizedBox(height: AppDimens.lg),
                  // 2. Main Title
                  Text(
                    langProvider.tr('appName'),
                    style: AppTypography.headlineLarge(isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.xs),
                  // 3. Tagline
                  Text(
                    langProvider.tr('tagline'),
                    style: AppTypography.bodyLarge(isDark)
                        .copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // 4. Friendly Collector Illustration
                  CollectorIllustration(
                    width: MediaQuery.of(context).size.width * 0.88,
                    height: 250,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppDimens.lg),
                  // 5. Bottom Brand Mission Line
                  Text(
                    langProvider.tr('splashFooter'),
                    style: AppTypography.bodyMedium(
                      isDark,
                    ).copyWith(fontStyle: FontStyle.italic, letterSpacing: 0.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.xl),
                  // 6. Modern Progress Indicator Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Color(0x22000000),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
