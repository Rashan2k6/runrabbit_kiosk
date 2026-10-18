import 'package:flutter/material.dart';

import 'brand.dart';

ThemeData buildTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Brand.primary,
    onPrimary: Brand.onPrimary,
    secondary: Brand.accent,
    onSecondary: Colors.white,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Brand.surface,
    onSurface: Brand.textPrimary,
    outline: Brand.outline,
    outlineVariant: Brand.outlineLight,
  );

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Brand.radius),
  );
  const minSize = Size(130, 60);

  return ThemeData(
    useMaterial3: true,
    fontFamily: Brand.fontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.background,
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minSize,
        elevation: 0,
        backgroundColor: Brand.primary,
        foregroundColor: Brand.onPrimary,
        shape: shape,
        textStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: shape,
        foregroundColor: Brand.primary,
        side: const BorderSide(color: Brand.outline, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(96, 60),
        foregroundColor: Brand.mutedText,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
