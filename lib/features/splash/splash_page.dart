import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../shared/sakinah_keys.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.autoAdvance = true,
  });

  final bool autoAdvance;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.autoAdvance) {
      return;
    }
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: SakinahKeys.splashPage,
      body: _SplashCanvas(),
    );
  }
}

class _SplashCanvas extends StatelessWidget {
  const _SplashCanvas();

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 430;
    final brandSize = compact ? 58.0 : 76.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBF6E8),
            Color(0xFFF4EFD8),
            Color(0xFFE5E9D6),
            Color(0xFF044135),
          ],
          stops: [0, 0.46, 0.68, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _SplashBackgroundPainter()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 22 : 34,
                vertical: compact ? 24 : 36,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 9),
                  const _CrescentMark(),
                  const SizedBox(height: 54),
                  Text(
                    'Sakinah\nDaily',
                    key: SakinahKeys.splashBrand,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SakinahColors.deepEmerald,
                      fontFamily: 'Georgia',
                      fontSize: brandSize,
                      height: 0.9,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _DividerOrnament(),
                  const SizedBox(height: 24),
                  Text(
                    l10n.t('splashTagline'),
                    key: SakinahKeys.splashTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SakinahColors.deepEmerald,
                      fontSize: compact ? 22 : 25,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'سكينة يومية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SakinahColors.sandGold.withValues(alpha: 0.78),
                      fontSize: compact ? 24 : 29,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(flex: 10),
                  const _BottomOrnament(),
                  const SizedBox(height: 34),
                  FittedBox(
                    child: Text(
                      l10n.t('splashFeatureLine'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SakinahColors.sandGold.withValues(alpha: 0.96),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrescentMark extends StatelessWidget {
  const _CrescentMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(112, 98),
      painter: _CrescentPainter(),
    );
  }
}

class _DividerOrnament extends StatelessWidget {
  const _DividerOrnament();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(190, 18),
      painter: _DividerPainter(),
    );
  }
}

class _BottomOrnament extends StatelessWidget {
  const _BottomOrnament();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(250, 42),
      painter: _BottomOrnamentPainter(),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintPattern(canvas, size);
    _paintArch(canvas, size);
    _paintMosqueSilhouette(canvas, size);
    _paintHills(canvas, size);
  }

  void _paintPattern(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = SakinahColors.sandGold.withValues(alpha: 0.16);
    final dot = Paint()
      ..style = PaintingStyle.fill
      ..color = SakinahColors.sandGold.withValues(alpha: 0.14);

    const gap = 54.0;
    const radius = 10.0;
    for (double y = 22; y < size.height * 0.55; y += gap) {
      for (double x = 20; x < size.width + gap; x += gap) {
        final shiftedX = x + ((y / gap).round().isEven ? 0 : gap / 2);
        final path = Path()
          ..moveTo(shiftedX, y - radius)
          ..lineTo(shiftedX + radius, y)
          ..lineTo(shiftedX, y + radius)
          ..lineTo(shiftedX - radius, y)
          ..close();
        canvas.drawPath(path, line);
        canvas.drawCircle(Offset(shiftedX, y), 2.2, dot);
      }
    }
  }

  void _paintArch(Canvas canvas, Size size) {
    final archWidth = size.width * 0.78;
    final left = (size.width - archWidth) / 2;
    final right = left + archWidth;
    final top = size.height * 0.095;
    final shoulder = size.height * 0.27;
    final base = size.height * 0.75;
    final centerX = size.width / 2;

    final arch = Path()
      ..moveTo(left, base)
      ..lineTo(left, shoulder)
      ..cubicTo(left, shoulder * 0.8, centerX * 0.58, top + 116, centerX, top)
      ..cubicTo(right - (centerX * 0.42), top + 116, right, shoulder * 0.8,
          right, shoulder)
      ..lineTo(right, base);

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.54)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = SakinahColors.sandGold.withValues(alpha: 0.62);

    canvas.drawPath(arch, shadow);
    canvas.drawPath(arch, outline);
  }

  void _paintMosqueSilhouette(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFD6D5C5).withValues(alpha: 0.22);
    final y = size.height * 0.58;
    final center = size.width / 2;

    Path dome(double cx, double width, double height) {
      return Path()
        ..moveTo(cx - width / 2, y + height)
        ..quadraticBezierTo(cx, y - height * 0.8, cx + width / 2, y + height)
        ..close();
    }

    canvas.drawPath(dome(center, size.width * 0.21, 98), paint);
    canvas.drawPath(
        dome(center - size.width * 0.18, size.width * 0.12, 74), paint);
    canvas.drawPath(
        dome(center + size.width * 0.18, size.width * 0.12, 74), paint);

    for (final x in [
      center - size.width * 0.32,
      center - size.width * 0.23,
      center + size.width * 0.23,
      center + size.width * 0.32,
    ]) {
      final minaret = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 4, y - 18, 8, 118),
        const Radius.circular(8),
      );
      canvas.drawRRect(minaret, paint);
      canvas.drawPath(
        Path()
          ..moveTo(x - 10, y - 18)
          ..quadraticBezierTo(x, y - 46, x + 10, y - 18)
          ..close(),
        paint,
      );
    }
  }

  void _paintHills(Canvas canvas, Size size) {
    final back = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2A6D60).withValues(alpha: 0.58);
    final mid = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1B5E52).withValues(alpha: 0.7);
    final front = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF073E35).withValues(alpha: 0.92);

    final h = size.height;
    final w = size.width;

    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.72)
        ..cubicTo(w * 0.18, h * 0.68, w * 0.3, h * 0.84, w * 0.5, h * 0.79)
        ..cubicTo(w * 0.68, h * 0.74, w * 0.78, h * 0.69, w, h * 0.72)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      back,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.75)
        ..cubicTo(w * 0.2, h * 0.7, w * 0.38, h * 0.86, w * 0.55, h * 0.81)
        ..cubicTo(w * 0.75, h * 0.75, w * 0.84, h * 0.68, w, h * 0.7)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      mid,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.78)
        ..cubicTo(w * 0.2, h * 0.84, w * 0.34, h * 0.94, w * 0.52, h * 0.88)
        ..cubicTo(w * 0.74, h * 0.82, w * 0.78, h * 0.74, w, h * 0.78)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      front,
    );
  }

  @override
  bool shouldRepaint(_SplashBackgroundPainter oldDelegate) => false;
}

class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFC79D45), Color(0xFFE1BE6B)],
      ).createShader(Offset.zero & size);

    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.48), 38, gold);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.43),
      36,
      Paint()..color = const Color(0xFFF3EEDA),
    );

    final star = Path();
    const cx = 82.0;
    const cy = 46.0;
    const r1 = 19.0;
    const r2 = 7.0;
    for (var i = 0; i < 8; i += 1) {
      final angle = -1.5708 + i * 0.7854;
      final r = i.isEven ? r1 : r2;
      final point = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();
    canvas.drawPath(star, gold);
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.73), 3.4, gold);
  }

  @override
  bool shouldRepaint(_CrescentPainter oldDelegate) => false;
}

class _DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.2
      ..color = SakinahColors.sandGold.withValues(alpha: 0.82);
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width * 0.42, y), paint);
    canvas.drawLine(Offset(size.width * 0.58, y), Offset(size.width, y), paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width / 2 + 9, y)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width / 2 - 9, y)
        ..close(),
      Paint()..color = SakinahColors.sandGold,
    );
  }

  @override
  bool shouldRepaint(_DividerPainter oldDelegate) => false;
}

class _BottomOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = SakinahColors.sandGold.withValues(alpha: 0.9);
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width * 0.36, y), paint);
    canvas.drawLine(Offset(size.width * 0.64, y), Offset(size.width, y), paint);

    final center = Offset(size.width / 2, y);
    for (var i = 0; i < 4; i += 1) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * 1.5708);
      canvas.drawPath(
        Path()
          ..moveTo(0, -24)
          ..quadraticBezierTo(15, -8, 0, 0)
          ..quadraticBezierTo(-15, -8, 0, -24),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, 5, paint);
  }

  @override
  bool shouldRepaint(_BottomOrnamentPainter oldDelegate) => false;
}
