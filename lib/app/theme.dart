import 'package:flutter/material.dart';

import 'brand.dart';

ThemeData buildTheme([String lang = 'en']) {
  final isSi = lang == 'si';
  final fontFamily = isSi ? Brand.sinhalaFontFamily : Brand.fontFamily;
  final height = isSi ? Brand.sinhalaLineHeight : null;

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

  var textTheme = Typography.material2021().black;
  if (isSi) {
    TextStyle applySi(TextStyle? s) {
      if (s == null) return TextStyle(fontFamily: fontFamily, height: height);
      return s.copyWith(fontFamily: fontFamily, height: height);
    }

    textTheme = textTheme.copyWith(
      displayLarge: applySi(textTheme.displayLarge),
      displayMedium: applySi(textTheme.displayMedium),
      displaySmall: applySi(textTheme.displaySmall),
      headlineLarge: applySi(textTheme.headlineLarge),
      headlineMedium: applySi(textTheme.headlineMedium),
      headlineSmall: applySi(textTheme.headlineSmall),
      titleLarge: applySi(textTheme.titleLarge),
      titleMedium: applySi(textTheme.titleMedium),
      titleSmall: applySi(textTheme.titleSmall),
      bodyLarge: applySi(textTheme.bodyLarge),
      bodyMedium: applySi(textTheme.bodyMedium),
      bodySmall: applySi(textTheme.bodySmall),
      labelLarge: applySi(textTheme.labelLarge),
      labelMedium: applySi(textTheme.labelMedium),
      labelSmall: applySi(textTheme.labelSmall),
    );
  }

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    textTheme: isSi ? textTheme : null,
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
        textStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontFamily: fontFamily,
          height: height,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: shape,
        foregroundColor: Brand.primary,
        side: const BorderSide(color: Brand.outline, width: 1.5),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          fontFamily: fontFamily,
          height: height,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(96, 60),
        foregroundColor: Brand.mutedText,
        textStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
          height: height,
        ),
      ),
    ),
  );
}
