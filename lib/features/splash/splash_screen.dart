import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/welcome_screen.dart';

/// First thing shown on cold start: brand mark, tagline, and a hero
/// illustration, before handing off to [WelcomeScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _displayDuration = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    Future.delayed(_displayDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const WelcomeScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A1830);
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _BackgroundGlyphs(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 56),
                const _HexLogo(),
                const SizedBox(height: 20),
                Text(
                  'ULTRAQUAD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code. Contribute. Grow.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                const AspectRatio(
                  aspectRatio: 320 / 260,
                  child: CustomPaint(
                    painter: _DeskScenePainter(),
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint scattered tech glyphs behind the brand mark.
class _BackgroundGlyphs extends StatelessWidget {
  const _BackgroundGlyphs();

  @override
  Widget build(BuildContext context) {
    final glyph = TextStyle(
      color: AppColors.mint.withValues(alpha: 0.08),
      fontSize: 34,
      fontWeight: FontWeight.bold,
    );
    return Stack(
      children: [
        Positioned(top: 70, left: 24, child: Text('{ }', style: glyph)),
        Positioned(top: 40, right: 28, child: Icon(Icons.settings, size: 30, color: AppColors.mint.withValues(alpha: 0.08))),
        Positioned(top: 150, right: 50, child: Text('</>', style: glyph.copyWith(fontSize: 22))),
        Positioned(bottom: 260, left: 40, child: Icon(Icons.cloud_outlined, size: 28, color: AppColors.mint.withValues(alpha: 0.07))),
      ],
    );
  }
}

/// Hexagonal brand mark with a "UQ" monogram, matching the app icon.
class _HexLogo extends StatelessWidget {
  const _HexLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(68, 68), painter: _HexagonPainter()),
          const Text(
            'UQ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter();

  List<Offset> _hexPoints(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;
    return List.generate(6, (i) {
      final angle = i * math.pi / 3;
      return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final points = _hexPoints(size);
    final path = Path()..addPolygon(points, true);

    canvas.drawPath(
      path,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.mint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized flat-shape scene: a person coding at a desk with a monitor,
/// laptop, plant, and mug, rendered as a duotone illustration matching
/// the app palette.
class _DeskScenePainter extends CustomPainter {
  const _DeskScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double x(double f) => f * w;
    double y(double f) => f * h;

    final deskPaint = Paint()..color = AppColors.teal.withValues(alpha: 0.85);
    final deskLegPaint = Paint()..color = AppColors.teal.withValues(alpha: 0.55);
    final chairPaint = Paint()..color = const Color(0xFF16305C);
    final hoodiePaint = Paint()..color = const Color(0xFF2C3E63);
    final hoodShadePaint = Paint()..color = const Color(0xFF233252);
    final skinPaint = Paint()..color = const Color(0xFFC98A5B);
    final monitorFramePaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final monitorScreenPaint = Paint()..color = const Color(0xFF0B1830);
    final laptopBasePaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final laptopScreenPaint = Paint()..color = AppColors.navyLight;
    final potPaint = Paint()..color = const Color(0xFF1B3A6B);
    final leafPaint = Paint()..color = AppColors.mint.withValues(alpha: 0.9);
    final leafPaint2 = Paint()..color = AppColors.green.withValues(alpha: 0.85);
    final mugPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);

    // Chair back, drawn first so the person sits in front of it.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x(0.66), y(0.28), x(0.90), y(0.70)),
        const Radius.circular(18),
      ),
      chairPaint,
    );

    // Monitor stand + screen.
    canvas.drawRect(Rect.fromLTRB(x(0.30), y(0.62), x(0.37), y(0.68)), deskLegPaint);
    final monitorRect = Rect.fromLTRB(x(0.20), y(0.33), x(0.47), y(0.63));
    final monitorRRect = RRect.fromRectAndRadius(monitorRect, const Radius.circular(6));
    canvas.drawRRect(monitorRRect, monitorScreenPaint);
    canvas.drawRRect(monitorRRect, monitorFramePaint);
    final codeLineWidths = [0.55, 0.75, 0.4, 0.65];
    for (var i = 0; i < codeLineWidths.length; i++) {
      final lineY = y(0.40 + i * 0.055);
      canvas.drawLine(
        Offset(x(0.24), lineY),
        Offset(x(0.24) + codeLineWidths[i] * (monitorRect.width - 8), lineY),
        Paint()
          ..color = AppColors.mint.withValues(alpha: i.isEven ? 0.75 : 0.45)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Desk surface + legs.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x(0.10), y(0.63), x(0.94), y(0.68)),
        const Radius.circular(4),
      ),
      deskPaint,
    );
    canvas.drawRect(Rect.fromLTRB(x(0.15), y(0.68), x(0.19), y(0.92)), deskLegPaint);
    canvas.drawRect(Rect.fromLTRB(x(0.85), y(0.68), x(0.89), y(0.92)), deskLegPaint);

    // Laptop in front of the person.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x(0.50), y(0.585), x(0.72), y(0.63)),
        const Radius.circular(3),
      ),
      laptopBasePaint,
    );
    final laptopScreen = Path()
      ..moveTo(x(0.515), y(0.585))
      ..lineTo(x(0.545), y(0.44))
      ..lineTo(x(0.685), y(0.44))
      ..lineTo(x(0.705), y(0.585))
      ..close();
    canvas.drawPath(laptopScreen, laptopScreenPaint);

    // Person: hood, head, body, and an arm reaching to the laptop.
    final body = Path()
      ..moveTo(x(0.73), y(0.92))
      ..lineTo(x(0.735), y(0.62))
      ..quadraticBezierTo(x(0.74), y(0.50), x(0.80), y(0.50))
      ..quadraticBezierTo(x(0.865), y(0.50), x(0.87), y(0.62))
      ..lineTo(x(0.875), y(0.92))
      ..close();
    canvas.drawPath(body, hoodiePaint);

    final hood = Path()
      ..moveTo(x(0.735), y(0.50))
      ..quadraticBezierTo(x(0.72), y(0.40), x(0.80), y(0.375))
      ..quadraticBezierTo(x(0.88), y(0.40), x(0.868), y(0.50))
      ..quadraticBezierTo(x(0.80), y(0.46), x(0.735), y(0.50))
      ..close();
    canvas.drawPath(hood, hoodShadePaint);

    canvas.drawCircle(Offset(x(0.80), y(0.415)), h * 0.062, skinPaint);

    // Arm reaching forward to the laptop keyboard.
    final arm = Path()
      ..moveTo(x(0.745), y(0.56))
      ..quadraticBezierTo(x(0.62), y(0.565), x(0.545), y(0.60))
      ..lineTo(x(0.55), y(0.625))
      ..quadraticBezierTo(x(0.63), y(0.60), x(0.755), y(0.595))
      ..close();
    canvas.drawPath(arm, hoodiePaint);

    // Plant, right of the monitor.
    final potPath = Path()
      ..moveTo(x(0.905), y(0.60))
      ..lineTo(x(0.955), y(0.60))
      ..lineTo(x(0.945), y(0.635))
      ..lineTo(x(0.915), y(0.635))
      ..close();
    canvas.drawPath(potPath, potPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(x(0.917), y(0.565)), width: w * 0.05, height: h * 0.09), leafPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(x(0.945), y(0.575)), width: w * 0.045, height: h * 0.08), leafPaint2);
    canvas.drawOval(Rect.fromCenter(center: Offset(x(0.93), y(0.545)), width: w * 0.035, height: h * 0.07), leafPaint);

    // Mug, left edge of the desk.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x(0.115), y(0.58), x(0.16), y(0.63)),
        const Radius.circular(3),
      ),
      mugPaint,
    );
    canvas.drawArc(
      Rect.fromLTRB(x(0.16), y(0.585), x(0.185), y(0.62)),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = mugPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
