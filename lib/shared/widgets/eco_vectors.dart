import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Clean, scalable vector illustrations crafted specifically for Kabadiwala Connect.
/// Renders crisp graphics on any screen density without external asset loading delays.

// ==================== 1. BRAND RECYCLING LEAF LOGO ====================
class EcoRecycleLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const EcoRecycleLogo({super.key, this.size = 80, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _EcoRecycleLogoPainter(isDark: isDark)),
    );
  }
}

class _EcoRecycleLogoPainter extends CustomPainter {
  final bool isDark;
  _EcoRecycleLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final greenPrimary = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final greenSecondary = isDark
        ? const Color(0xFF10B981)
        : const Color(0xFF16A34A);
    final greenTertiary = isDark
        ? const Color(0xFF34D399)
        : const Color(0xFF4ADE80);

    final colors = [greenPrimary, greenSecondary, greenTertiary];

    // Draw 3 curved leaf-shaped recycling ribbons
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120.0) * math.pi / 180.0;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final path = Path();
      // Draw stylized aerodynamic recycling leaf arrow
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

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _EcoRecycleLogoPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ==================== 2. FRIENDLY COLLECTOR ILLUSTRATION ====================
class CollectorIllustration extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;

  const CollectorIllustration({
    super.key,
    this.width = 300,
    this.height = 240,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _CollectorPainter(isDark: isDark)),
    );
  }
}

class _CollectorPainter extends CustomPainter {
  final bool isDark;
  _CollectorPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background City Skyline & Soft Green Hill
    final hillPaint = Paint()
      ..color = isDark ? const Color(0xFF0F261B) : const Color(0xFFDCFCE7)
      ..style = PaintingStyle.fill;

    final hillPath = Path();
    hillPath.moveTo(0, h * 0.65);
    hillPath.quadraticBezierTo(w * 0.4, h * 0.45, w, h * 0.6);
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 2. City Skyline Silhouette
    final bldgPaint = Paint()
      ..color = isDark ? const Color(0xFF143324) : const Color(0xFFBBF7D0)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.05, h * 0.35, w * 0.12, h * 0.3),
      bldgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.1, h * 0.37),
      bldgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.72, h * 0.32, w * 0.11, h * 0.33),
      bldgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.84, h * 0.4, w * 0.12, h * 0.25),
      bldgPaint,
    );

    // 3. Mini Green Tempo / E-Vehicle on the left
    final truckPaint = Paint()
      ..color = isDark ? const Color(0xFF166534) : const Color(0xFF15803D)
      ..style = PaintingStyle.fill;
    final truckCabin = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.6, w * 0.16, h * 0.12),
      const Radius.circular(6),
    );
    canvas.drawRRect(truckCabin, truckPaint);

    final wheelPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(w * 0.08, h * 0.73), w * 0.025, wheelPaint);
    canvas.drawCircle(Offset(w * 0.16, h * 0.73), w * 0.025, wheelPaint);

    // 4. Collector (Ramesh)
    final cx = w * 0.52;
    final cy = h * 0.55;

    // Body (Green Uniform Polo)
    final uniformPaint = Paint()
      ..color = isDark
          ? AppColors.primaryGreenDark
          : AppColors.primaryGreenLight
      ..style = PaintingStyle.fill;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.2, cy - h * 0.08, w * 0.4, h * 0.38),
      const Radius.circular(24),
    );
    canvas.drawRRect(bodyRect, uniformPaint);

    // Collar
    final collarPaint = Paint()
      ..color = isDark ? const Color(0xFF166534) : const Color(0xFF0D5C3A)
      ..style = PaintingStyle.fill;
    final collarPath = Path();
    collarPath.moveTo(cx - w * 0.08, cy - h * 0.08);
    collarPath.lineTo(cx, cy - h * 0.01);
    collarPath.lineTo(cx + w * 0.08, cy - h * 0.08);
    canvas.drawPath(collarPath, collarPaint);

    // Neck & Head
    final skinPaint = Paint()..color = const Color(0xFFE0A96D);
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.04, cy - h * 0.14, w * 0.08, h * 0.08),
      skinPaint,
    );

    // Head
    canvas.drawCircle(Offset(cx, cy - h * 0.2), w * 0.11, skinPaint);

    // Smile & Mustache
    final facialPaint = Paint()
      ..color = const Color(0xFF452205)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Friendly smile
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy - h * 0.18), radius: w * 0.04),
      0.1,
      math.pi * 0.8,
      false,
      facialPaint,
    );

    // Friendly Eyes
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(cx - w * 0.04, cy - h * 0.22), 3.0, eyePaint);
    canvas.drawCircle(Offset(cx + w * 0.04, cy - h * 0.22), 3.0, eyePaint);

    // Green Cap
    final capPaint = Paint()..color = uniformPaint.color;
    final capPath = Path();
    capPath.addArc(
      Rect.fromCircle(center: Offset(cx, cy - h * 0.24), radius: w * 0.115),
      math.pi,
      math.pi,
    );
    canvas.drawPath(capPath, capPaint);
    // Cap visor
    final visorPaint = Paint()..color = collarPaint.color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.04, cy - h * 0.26, w * 0.16, h * 0.035),
        const Radius.circular(4),
      ),
      visorPaint,
    );

    // 5. Cardboard Box Held in Hands
    final boxPaint = Paint()..color = const Color(0xFFD4A373);
    final boxRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.25, cy + h * 0.06, w * 0.5, h * 0.28),
      const Radius.circular(10),
    );
    canvas.drawRRect(boxRRect, boxPaint);

    // Green recycle symbol on box
    final boxLogoPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy + h * 0.19), w * 0.05, boxLogoPaint);

    // E-waste items sticking out of box (PC board, circuit, keyboard, cables)
    final ewasteCircuit = Paint()..color = const Color(0xFF065F46);
    canvas.drawRect(
      Rect.fromLTWH(cx - w * 0.18, cy - h * 0.01, w * 0.12, h * 0.09),
      ewasteCircuit,
    );

    final ewasteKey = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(
      Rect.fromLTWH(cx + w * 0.04, cy - h * 0.02, w * 0.14, h * 0.09),
      ewasteKey,
    );

    // Collector Arms holding the box
    final sleevePaint = Paint()..color = uniformPaint.color;
    canvas.drawCircle(
      Offset(cx - w * 0.24, cy + h * 0.15),
      w * 0.05,
      sleevePaint,
    );
    canvas.drawCircle(
      Offset(cx + w * 0.24, cy + h * 0.15),
      w * 0.05,
      sleevePaint,
    );
    canvas.drawCircle(
      Offset(cx - w * 0.22, cy + h * 0.16),
      w * 0.035,
      skinPaint,
    );
    canvas.drawCircle(
      Offset(cx + w * 0.22, cy + h * 0.16),
      w * 0.035,
      skinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CollectorPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ==================== 3. GREEN EARTH ILLUSTRATION (BANNER) ====================
class GreenEarthBanner extends StatelessWidget {
  final double height;
  final bool isDark;
  final String bannerText;

  const GreenEarthBanner({
    super.key,
    this.height = 190,
    this.isDark = false,
    required this.bannerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _GreenEarthPainter(isDark: isDark),
          ),
          Positioned(
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xDD0D2015)
                    : const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1F4832)
                      : const Color(0xFFBBF7D0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                bannerText,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFF166534),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenEarthPainter extends CustomPainter {
  final bool isDark;
  _GreenEarthPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curved green Earth globe dome at the bottom
    final globeCenter = Offset(w / 2, h * 1.35);
    final globeRadius = w * 0.75;

    final globePaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF1B4D33), const Color(0xFF0A2417)]
            : [const Color(0xFF4ADE80), const Color(0xFF16A34A)],
      ).createShader(Rect.fromCircle(center: globeCenter, radius: globeRadius));

    canvas.drawCircle(globeCenter, globeRadius, globePaint);

    // Decorative lush leaves emerging on top of globe
    final leafPaint = Paint()
      ..color = isDark ? const Color(0xFF22C55E) : const Color(0xFF86EFAC)
      ..style = PaintingStyle.fill;

    for (int i = -3; i <= 3; i++) {
      final x = w / 2 + i * (w * 0.12);
      final y = h * 0.45 + (i.abs() * 12);
      final leafPath = Path();
      leafPath.moveTo(x, y);
      leafPath.quadraticBezierTo(x - 12, y - 24, x, y - 36);
      leafPath.quadraticBezierTo(x + 12, y - 24, x, y);
      canvas.drawPath(leafPath, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GreenEarthPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ==================== 4. VERNACULAR CULTURAL ICONS ====================
class IndiaGatewayIcon extends StatelessWidget {
  final bool isDark;
  const IndiaGatewayIcon({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F3020) : const Color(0xFFDCFCE7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_rounded,
          size: 24,
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        ),
      ),
    );
  }
}

class MaharashtraFortIcon extends StatelessWidget {
  final bool isDark;
  const MaharashtraFortIcon({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332005) : const Color(0xFFFEF3C7),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.shield_moon_rounded,
          size: 24,
          color: Color(0xFFD97706),
        ),
      ),
    );
  }
}

class EnglishGlobeIcon extends StatelessWidget {
  final bool isDark;
  const EnglishGlobeIcon({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10283B) : const Color(0xFFE0F2FE),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.public_rounded, size: 24, color: Color(0xFF0284C7)),
      ),
    );
  }
}
