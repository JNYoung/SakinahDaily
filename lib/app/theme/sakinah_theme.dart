import 'package:flutter/material.dart';

class SakinahColors {
  static const deepEmerald = Color(0xFF0E3B2E);
  static const midnightNavy = Color(0xFF101B2D);
  static const sandGold = Color(0xFFC9A45C);
  static const ivory = Color(0xFFF7F2E8);
  static const sageGreen = Color(0xFFAABFA3);
  static const warmTaupe = Color(0xFFB8A897);
  static const ink = Color(0xFF1D2624);
  static const cardIvory = Color(0xFFFFFAF1);
  static const mutedText = Color(0xFF7F7468);
  static const navyCard = Color(0xFF18263D);
}

class SakinahTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: SakinahColors.deepEmerald,
      brightness: Brightness.light,
      primary: SakinahColors.deepEmerald,
      secondary: SakinahColors.sandGold,
      surface: SakinahColors.ivory,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SakinahColors.ivory,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      textTheme: _textTheme(Brightness.light),
      cardTheme: CardThemeData(
        color: SakinahColors.cardIvory,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SakinahColors.sandGold,
          foregroundColor: SakinahColors.deepEmerald,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SakinahColors.ivory,
        selectedColor: SakinahColors.deepEmerald,
        side:
            BorderSide(color: SakinahColors.warmTaupe.withValues(alpha: 0.28)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: SakinahColors.cardIvory,
        indicatorColor: SakinahColors.ivory,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 20,
            color: selected ? SakinahColors.sandGold : SakinahColors.mutedText,
          );
        }),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: SakinahColors.sageGreen,
      brightness: Brightness.dark,
      primary: SakinahColors.sageGreen,
      secondary: SakinahColors.sandGold,
      surface: SakinahColors.midnightNavy,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SakinahColors.midnightNavy,
      textTheme: _textTheme(Brightness.dark),
      cardTheme: CardThemeData(
        color: SakinahColors.navyCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: SakinahColors.sandGold,
          foregroundColor: SakinahColors.midnightNavy,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: SakinahColors.navyCard,
        indicatorColor: SakinahColors.midnightNavy,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 20,
            color: selected ? SakinahColors.sandGold : Colors.white60,
          );
        }),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final color =
        brightness == Brightness.dark ? Colors.white : SakinahColors.ink;
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: color,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
        color:
            brightness == Brightness.dark ? Colors.white70 : SakinahColors.ink,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        color: brightness == Brightness.dark
            ? Colors.white60
            : SakinahColors.mutedText,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}
