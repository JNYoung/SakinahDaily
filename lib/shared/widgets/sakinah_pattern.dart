import 'package:flutter/material.dart';

import '../../app/theme/sakinah_theme.dart';

class SakinahPattern extends StatelessWidget {
  const SakinahPattern({
    required this.child,
    this.dark = false,
    super.key,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SakinahPatternPainter(dark: dark),
      child: child,
    );
  }
}

class _SakinahPatternPainter extends CustomPainter {
  const _SakinahPatternPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (dark ? SakinahColors.sandGold : SakinahColors.sandGold)
          .withValues(alpha: dark ? 0.56 : 0.34);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (dark ? SakinahColors.sandGold : SakinahColors.sandGold)
          .withValues(alpha: dark ? 0.62 : 0.42);

    const gap = 46.0;
    const radius = 8.0;
    for (double y = 22; y < size.height + gap; y += gap) {
      for (double x = 22; x < size.width + gap; x += gap) {
        final path = Path()
          ..moveTo(x, y - radius)
          ..lineTo(x + radius, y)
          ..lineTo(x, y + radius)
          ..lineTo(x - radius, y)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SakinahPatternPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}
