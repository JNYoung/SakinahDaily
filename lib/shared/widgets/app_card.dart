import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = 28,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: card,
    );
  }
}
