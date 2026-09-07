import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';

/// Reusable Primary Action button with micro-interaction scale feedback
class PrimaryButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback onPressed;
  final double height;
  final EdgeInsetsGeometry? margin;

  const PrimaryButton({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onPressed,
    this.height = AppDimens.buttonHeightHero,
    this.margin,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const bgGradient = LinearGradient(
      colors: [Color(0xFF16A34A), Color(0xFF15803D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x6622C55E)
                    : const Color(0x4015803D),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => _animController.forward(),
              onTapUp: (_) {
                _animController.reverse();
                widget.onPressed();
              },
              onTapCancel: () => _animController.reverse(),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: AppDimens.md),
                    ],
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.buttonHero(isDark),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: AppTypography.buttonHeroSub(isDark),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
