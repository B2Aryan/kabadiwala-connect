import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Cinematic eco-story hero mark that narrates:
/// E-WASTE → COLLECTION → RECYCLING → GREEN FUTURE
///
/// Fully native Flutter vector animation, zero external dependencies.
/// Driven by a single AnimationController (0.0 → 1.0 over ~3200ms).
class AnimatedEcoHeroMark extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final bool isDark;

  const AnimatedEcoHeroMark({
    super.key,
    required this.animation,
    this.size = 120,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _EcoHeroMarkPainter(
              progress: animation.value,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data: one eco-particle per emission point
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  final double startAngle; // radians from center
  final double distance; // final radial distance in px
  final double phaseOffset; // 0.0–1.0 offset into particle lifetime
  final double sizeScale; // 0.5–1.0

  const _Particle({
    required this.startAngle,
    required this.distance,
    required this.phaseOffset,
    required this.sizeScale,
  });
}

const List<_Particle> _particles = [
  _Particle(
    startAngle: -math.pi / 2,
    distance: 28,
    phaseOffset: 0.0,
    sizeScale: 0.9,
  ),
  _Particle(
    startAngle: -math.pi / 4,
    distance: 36,
    phaseOffset: 0.08,
    sizeScale: 0.7,
  ),
  _Particle(
    startAngle: -math.pi * 0.75,
    distance: 32,
    phaseOffset: 0.15,
    sizeScale: 0.8,
  ),
  _Particle(
    startAngle: -math.pi / 6,
    distance: 42,
    phaseOffset: 0.05,
    sizeScale: 0.6,
  ),
  _Particle(
    startAngle: -math.pi * 0.9,
    distance: 38,
    phaseOffset: 0.20,
    sizeScale: 0.75,
  ),
  _Particle(
    startAngle: -math.pi / 3,
    distance: 30,
    phaseOffset: 0.12,
    sizeScale: 0.65,
  ),
  _Particle(
    startAngle: -math.pi * 0.6,
    distance: 44,
    phaseOffset: 0.18,
    sizeScale: 0.85,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Painter — all stages computed from [progress] in [0.0, 1.0]
// ─────────────────────────────────────────────────────────────────────────────
class _EcoHeroMarkPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _EcoHeroMarkPainter({required this.progress, required this.isDark});

  // ---- helpers ----
  static double _interval(
    double t,
    double start,
    double end, {
    Curve curve = Curves.linear,
  }) {
    if (end <= start) return t >= end ? 1.0 : 0.0;
    return curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;

    final greenPrimary = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    const greenSecondary = Color(0xFF10B981);
    const greenTertiary = Color(0xFF34D399);
    final ribbonColors = [greenPrimary, greenSecondary, greenTertiary];

    final eWasteColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    // =========================================================================
    // 1. RECYCLING LOOP ASSEMBLY  (t 0.00 → 0.38)
    //    Arrows rotate in from -55° and lock into final position.
    //    After 0.38, a very slow organic drift continues.
    // =========================================================================
    final assembleT = _interval(
      progress,
      0.0,
      0.38,
      curve: Curves.easeOutCubic,
    );
    final assembleScale = 0.70 + (0.30 * assembleT);
    // Start 55° behind, snap forward with slight overshoot absorbed by easeOutCubic
    final assembleRotation = (1.0 - assembleT) * (-math.pi * 0.30);

    // Slow ambient idle rotation after assembly (very subtle — ~5° over the rest)
    final idleRotation = progress >= 0.38
        ? (progress - 0.38) / (1.0 - 0.38) * (math.pi * 0.085)
        : 0.0;

    // =========================================================================
    // 2. PULSE RIPPLE when absorption completes (t 0.40 → 0.52)
    // =========================================================================
    if (progress >= 0.40 && progress <= 0.52) {
      final pulseT = _interval(progress, 0.40, 0.52);
      // Two rings: primary expands fast, secondary slightly delayed
      _drawRipple(canvas, center, radius, pulseT, 0.0, greenPrimary);
      if (pulseT > 0.15) {
        _drawRipple(canvas, center, radius, pulseT, 0.15, greenSecondary);
      }
    }

    // =========================================================================
    // 3. E-WASTE DEVICES — orbit entrance (t 0.09 → 0.46)
    //    5 devices start at 1.9× radius, follow curved inward spiral paths,
    //    fade in quickly, then dissolve as they reach the recycling loop.
    // =========================================================================
    if (progress >= 0.09 && progress <= 0.46) {
      final eProgress = _interval(
        progress,
        0.09,
        0.46,
        curve: Curves.easeInOutSine,
      );

      // Staggered phase offsets so devices arrive at slightly different times
      final deviceDefs = [
        // (startAngle, phaseDelay, type)
        (math.pi / 6, 0.0, 0), // Smartphone — top-right
        (5 * math.pi / 6, 0.06, 1), // Laptop — top-left
        (9 * math.pi / 6, 0.10, 2), // Monitor — bottom
        (-math.pi / 4, 0.04, 3), // Plug — right
        (math.pi * 0.9, 0.08, 4), // Chip — left
      ];

      for (final (startAngle, delay, type) in deviceDefs) {
        final devT = ((eProgress - delay) / (1.0 - delay)).clamp(0.0, 1.0);

        // Curved orbit path: start 1.9× radius, spiral inward with slight arc
        final orbitAngle =
            startAngle + devT * (math.pi * 0.18); // slight orbital sweep
        final currentDist =
            radius * (1.9 - 0.95 * Curves.easeInQuart.transform(devT));

        // Fade: quick in (0→0.25) then dissolve (0.65→1.0)
        final eOpacity = devT < 0.25
            ? devT / 0.25
            : devT > 0.65
            ? (1.0 - (devT - 0.65) / 0.35).clamp(0.0, 1.0)
            : 1.0;

        final pos =
            center +
            Offset(math.cos(orbitAngle), math.sin(orbitAngle)) * currentDist;

        // Slight ambient float: bob up/down while orbiting
        final floatOffset = math.sin(devT * math.pi * 2.5) * 1.8;
        final drawPos = pos + Offset(0, floatOffset);

        _drawEWasteDevice(
          canvas,
          drawPos,
          type,
          eOpacity * 0.92,
          eWasteColor,
          scale: 0.90 * (1.0 - devT * 0.25),
        );
      }
    }

    // =========================================================================
    // 4. DRAW THE 3 RECYCLING RIBBONS
    //    Positioned at center, scaled, and rotated per assembly progress.
    // =========================================================================
    // Subtle brightness boost during pulse phase
    final pulseBrightness = (progress >= 0.40 && progress <= 0.52)
        ? _interval(progress, 0.40, 0.52) * 0.3
        : 0.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(assembleScale);
    canvas.rotate(assembleRotation + idleRotation);

    for (int i = 0; i < 3; i++) {
      final angle = (i * 120.0) * math.pi / 180.0;
      // Stagger each ribbon's assembly: ribbon i starts slightly after 0
      final ribbonT = _interval(
        progress,
        0.0 + i * 0.025,
        0.35 + i * 0.025,
        curve: Curves.easeOutCubic,
      );
      Color ribbonColor = ribbonColors[i];
      if (pulseBrightness > 0) {
        ribbonColor = Color.lerp(
          ribbonColor,
          Colors.white,
          pulseBrightness * 0.55,
        )!;
      }

      final ribbonPaint = Paint()
        ..color = ribbonColor.withValues(
          alpha: (0.3 + 0.7 * ribbonT).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      // Each ribbon rotates from slightly behind its target angle
      final ribbonStartOffset = (1.0 - ribbonT) * (-math.pi * 0.12);
      canvas.rotate(angle + ribbonStartOffset);

      final path = _buildRibbonPath(radius);
      canvas.drawPath(path, ribbonPaint);
      canvas.restore();
    }
    canvas.restore();

    // =========================================================================
    // 5. ECO PARTICLES — upward float after recycling (t 0.48 → 0.90)
    // =========================================================================
    if (progress >= 0.48) {
      final particleColor = isDark
          ? const Color(0xFF4ADE80)
          : const Color(0xFF22C55E);

      for (final p in _particles) {
        // Each particle lives for a portion of the total interval, staggered
        final pStart = 0.48 + p.phaseOffset * 0.18;
        final pEnd = pStart + 0.28;
        if (progress < pStart || progress > pEnd) continue;

        final pT = _interval(progress, pStart, pEnd, curve: Curves.easeOut);

        // Rise upward + slight lateral drift following startAngle
        final rise = pT * p.distance * 1.4;
        final lateral = math.cos(p.startAngle) * p.distance * 0.3 * pT;
        final particlePos = center + Offset(lateral, -rise);

        // Fade in fast, hold, then fade out
        final pOpacity = pT < 0.3
            ? pT / 0.3
            : (1.0 - (pT - 0.3) / 0.7).clamp(0.0, 1.0);

        final particlePaint = Paint()
          ..color = particleColor.withValues(alpha: pOpacity * 0.7)
          ..style = PaintingStyle.fill;

        final particleRadius = 2.5 * p.sizeScale * (1.0 - pT * 0.4);
        canvas.drawCircle(particlePos, particleRadius, particlePaint);
      }
    }

    // =========================================================================
    // 6. GREEN SPROUT — sequential growth from center (t 0.46 → 0.72)
    //    Stem → Left leaf → Right leaf, each with scale + fade + y-offset
    // =========================================================================
    if (progress >= 0.46) {
      final stemT = _interval(progress, 0.46, 0.58, curve: Curves.easeOutCubic);
      final leftLeafT = _interval(
        progress,
        0.53,
        0.65,
        curve: Curves.easeOutBack,
      );
      final rightLeafT = _interval(
        progress,
        0.59,
        0.72,
        curve: Curves.easeOutBack,
      );

      // Gentle sway after full growth
      final swayPhase = progress > 0.72
          ? (progress - 0.72) / 0.28 * math.pi * 4
          : 0.0;
      final swayAngle = math.sin(swayPhase) * 0.04;

      final sproutColor = isDark
          ? const Color(0xFF4ADE80)
          : const Color(0xFF16A34A);
      final sproutBright = isDark
          ? const Color(0xFF86EFAC)
          : const Color(0xFF22C55E);
      final stemColor = isDark
          ? const Color(0xFF166534)
          : const Color(0xFF14532D);

      canvas.save();
      canvas.translate(center.dx, center.dy + radius * 0.10);
      canvas.rotate(swayAngle);

      // Stem — grows from bottom up
      if (stemT > 0) {
        final stemPaint = Paint()
          ..color = stemColor.withValues(alpha: stemT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;

        final stemPath = Path();
        final stemTop = -18.0 * stemT; // grows upward
        stemPath.moveTo(0, 6);
        stemPath.quadraticBezierTo(1.5, -4, 0, stemTop);
        canvas.drawPath(stemPath, stemPaint);
      }

      // Left leaf
      if (leftLeafT > 0) {
        final leftPaint = Paint()
          ..color = sproutColor.withValues(alpha: leftLeafT)
          ..style = PaintingStyle.fill;
        final leftOutline = Paint()
          ..color = stemColor.withValues(alpha: leftLeafT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round;

        canvas.save();
        canvas.scale(leftLeafT);
        final leftLeaf = Path()
          ..moveTo(0, -12)
          ..cubicTo(-9, -14, -15, -21, -13, -27)
          ..cubicTo(-6, -27, -2, -20, 0, -12)
          ..close();
        canvas.drawPath(leftLeaf, leftPaint);
        canvas.drawPath(leftLeaf, leftOutline);
        canvas.restore();
      }

      // Right leaf (slightly brighter, higher)
      if (rightLeafT > 0) {
        final rightPaint = Paint()
          ..color = sproutBright.withValues(alpha: rightLeafT)
          ..style = PaintingStyle.fill;
        final rightOutline = Paint()
          ..color = stemColor.withValues(alpha: rightLeafT)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round;

        canvas.save();
        canvas.scale(rightLeafT);
        final rightLeaf = Path()
          ..moveTo(0, -16)
          ..cubicTo(9, -19, 15, -27, 12, -33)
          ..cubicTo(5, -32, 1, -24, 0, -16)
          ..close();
        canvas.drawPath(rightLeaf, rightPaint);
        canvas.drawPath(rightLeaf, rightOutline);
        canvas.restore();
      }

      canvas.restore();
    }
  }

  // ─── Ribbon path (same shape as before, extracted to method) ───────────────
  Path _buildRibbonPath(double radius) {
    final path = Path();
    path.moveTo(0, -radius);
    path.cubicTo(
      radius * 0.5,
      -radius * 0.95,
      radius * 0.8,
      -radius * 0.4,
      radius * 0.75,
      0,
    );
    path.lineTo(radius * 0.5, -radius * 0.15);
    path.lineTo(radius * 0.88, radius * 0.2);
    path.lineTo(radius * 1.05, -radius * 0.3);
    path.lineTo(radius * 0.85, -radius * 0.2);
    path.cubicTo(
      radius * 0.8,
      -radius * 0.7,
      radius * 0.4,
      -radius * 1.15,
      0,
      -radius,
    );
    path.close();
    return path;
  }

  // ─── Expanding ripple ring ──────────────────────────────────────────────────
  void _drawRipple(
    Canvas canvas,
    Offset center,
    double baseRadius,
    double pulseT,
    double phaseOffset,
    Color color,
  ) {
    final t = ((pulseT - phaseOffset) / (1.0 - phaseOffset)).clamp(0.0, 1.0);
    final ringRadius = baseRadius * (1.0 + t * 0.75);
    final opacity = (1.0 - t) * 0.45;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1.0 - t * 0.6);
    canvas.drawCircle(center, ringRadius, paint);
  }

  // ─── E-Waste device silhouette painters ────────────────────────────────────
  void _drawEWasteDevice(
    Canvas canvas,
    Offset pos,
    int type,
    double opacity,
    Color color, {
    double scale = 1.0,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    switch (type) {
      case 0: // Smartphone
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-5.5, -10, 11, 20),
            const Radius.circular(2.5),
          ),
          paint,
        );
        canvas.drawLine(const Offset(-2, -7), const Offset(2, -7), paint);
        canvas.drawCircle(const Offset(0, 6.5), 1.2, fillPaint);
        break;

      case 1: // Laptop
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-8, -9, 16, 10),
            const Radius.circular(1.5),
          ),
          paint,
        );
        canvas.drawLine(
          const Offset(-10, 2),
          const Offset(10, 2),
          paint..strokeWidth = 2.0,
        );
        paint.strokeWidth = 1.7;
        break;

      case 2: // Monitor
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-8, -8, 16, 12),
            const Radius.circular(2.0),
          ),
          paint,
        );
        canvas.drawLine(const Offset(0, 4), const Offset(0, 8), paint);
        canvas.drawLine(const Offset(-4, 8), const Offset(4, 8), paint);
        break;

      case 3: // Power plug / charger
        // Plug head
        canvas.drawRect(const Rect.fromLTWH(-4, -8, 8, 7), paint);
        // Prongs
        canvas.drawLine(const Offset(-2, -8), const Offset(-2, -11), paint);
        canvas.drawLine(const Offset(2, -8), const Offset(2, -11), paint);
        // Cable
        canvas.drawLine(const Offset(0, -1), const Offset(0, 8), paint);
        break;

      case 4: // Circuit chip
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-7, -7, 14, 14),
            const Radius.circular(2.0),
          ),
          paint,
        );
        // Pins left
        canvas.drawLine(const Offset(-7, -3), const Offset(-10, -3), paint);
        canvas.drawLine(const Offset(-7, 3), const Offset(-10, 3), paint);
        // Pins right
        canvas.drawLine(const Offset(7, -3), const Offset(10, -3), paint);
        canvas.drawLine(const Offset(7, 3), const Offset(10, 3), paint);
        // Inner dots
        canvas.drawCircle(const Offset(-2.5, -2.5), 0.8, fillPaint);
        canvas.drawCircle(const Offset(2.5, 2.5), 0.8, fillPaint);
        canvas.drawCircle(const Offset(-2.5, 2.5), 0.8, fillPaint);
        canvas.drawCircle(const Offset(2.5, -2.5), 0.8, fillPaint);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EcoHeroMarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
