// theme.dart
import 'package:flutter/material.dart';

// 앱 주요 컬러
class AppColors {
  // Brand
  static const Color brand = Color(0xFFF95934);

  // Neutrals
  static const Color n900 = Color(0xFF1E1E1E);
  static const Color n800 = Color(0xFF272727);
  static const Color n700 = Color(0xFF323232);
  static const Color n600 = Color(0xFF858585);
  static const Color n400 = Color(0xFFDBDBDB);
  static const Color n300 = Color(0xFFEEEEEE);
  static const Color n100 = Color(0xFFF1F2F3);
}

// TypoGraphy
class AppTypography {
  // Font family
  static const family = 'SpoqaHanSansNeo';

  // Size
  static const s42 = 42.0;
  static const s32 = 32.0;
  static const s24 = 24.0;
  static const s20 = 20.0;
  static const s18 = 18.0;
  static const s16 = 16.0;
  static const s14 = 14.0;
  static const s12 = 12.0;
  static const s10 = 10.0;

  // Weight (Spoqa: Bold=700, Medium=500, Regular=400, Light=300)
  static const bold = FontWeight.w700;
  static const medium = FontWeight.w500;
  static const regular = FontWeight.w400;
  static const light = FontWeight.w300;

  /// 공통 베이스 (한 곳에서 라인하이트/자간 정책 통제)
  static TextStyle style(
    double size, {
    FontWeight weight = regular,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    // 큰 타이틀은 타이트, 본문은 여유
    final defaultHeight = size >= 18 ? 1.2 : 1.5;
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height ?? defaultHeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// ColorScheme를 받아 M3 TextTheme 구성
  static TextTheme textTheme(ColorScheme cs) {
    final on = cs.onSurface;

    return TextTheme(
      // Display / Headline
      displayLarge: style(s42, weight: bold, color: on, height: 1.1), // H1
      displayMedium: style(s32, weight: bold, color: on, height: 1.1), // H2
      headlineLarge: style(s24, weight: bold, color: on), // H3
      headlineMedium: style(s20, weight: medium, color: on), // H4
      headlineSmall: style(s18, weight: medium, color: on),

      // Title
      titleLarge: style(s18, weight: medium, color: on),
      titleMedium: style(s16, weight: medium, color: on),
      titleSmall: style(s14, weight: medium, color: on),

      // Body
      bodyLarge: style(s16, weight: regular, color: on, height: 1.5),
      bodyMedium: style(s14, weight: regular, color: on, height: 1.5),
      bodySmall: style(s12, weight: regular, color: on, height: 1.45),

      // Label (버튼/뱃지/캡션)
      labelLarge: style(s14, weight: medium, color: on),
      labelMedium: style(s12, weight: medium, color: on, letterSpacing: 0.1),
      labelSmall: style(s10, weight: medium, color: on, letterSpacing: 0.2),
    );
  }

  // 자주 쓰는 프리셋(선택) — 필요 시 사용
  static TextStyle h1([Color? c]) =>
      style(s42, weight: bold, color: c, height: 1.1);
  static TextStyle h2([Color? c]) =>
      style(s32, weight: bold, color: c, height: 1.1);
  static TextStyle h3([Color? c]) => style(s24, weight: bold, color: c);
  static TextStyle title([Color? c]) => style(s18, weight: medium, color: c);
  static TextStyle body([Color? c]) =>
      style(s14, weight: regular, color: c, height: 1.5);
  static TextStyle caption([Color? c]) =>
      style(s12, weight: regular, color: c, height: 1.45);
  static TextStyle labelXS([Color? c]) =>
      style(s10, weight: medium, color: c, letterSpacing: .2);
}

/// =========================
/// ThemeData (Light/Dark)
/// =========================
class AppTheme {
  // Light ColorScheme
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brand,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFFFD5C9),
    onPrimaryContainer: Color(0xFF3B0A00),

    secondary: Color(0xFF272727),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFEDEEEF),
    onSecondaryContainer: Color(0xFF272727),

    tertiary: Color(0xFF006B6B),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF9CE7E1),
    onTertiaryContainer: Color(0xFF002020),

    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    surface: Colors.white,
    onSurface: AppColors.n900,
    surfaceContainerHigh: AppColors.n100,
    onSurfaceVariant: AppColors.n700,

    outline: AppColors.n300,
    outlineVariant: Color(0xFFDEE3E7),

    shadow: Colors.black,
    scrim: Colors.black,

    inverseSurface: Color(0xFF2B2B2B),
    onInverseSurface: Color(0xFFF1F1F1),
    inversePrimary: Color(0xFFC94020),

    surfaceTint: AppColors.brand,
  );

  // Dark ColorScheme
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.brand,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF7A210C),
    onPrimaryContainer: Color(0xFFFFEDE7),

    secondary: Color(0xFFBFC3C7),
    onSecondary: Color(0xFF121212),
    secondaryContainer: Color(0xFF2F3236),
    onSecondaryContainer: Colors.white,

    tertiary: Color(0xFF73D1CB),
    onTertiary: Color(0xFF002726),
    tertiaryContainer: Color(0xFF004F4E),
    onTertiaryContainer: Colors.white,

    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    surface: Color(0xFF121212),
    onSurface: Colors.white,
    surfaceContainerHigh: Color(0xFF1E1F22),
    onSurfaceVariant: Color(0xFFCACDD1),

    outline: Color(0xFF41464B),
    outlineVariant: Color(0xFF2E3237),

    shadow: Colors.black,
    scrim: Colors.black,

    inverseSurface: Color(0xFFE8E9EA),
    onInverseSurface: Color(0xFF1A1B1C),
    inversePrimary: Color(0xFFFFB59F),

    surfaceTint: AppColors.brand,
  );

  static ThemeData lightTheme = _buildTheme(lightScheme);
  static ThemeData darkTheme = _buildTheme(darkScheme);

  static ThemeData _buildTheme(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: AppTypography.family,
      textTheme: AppTypography.textTheme(cs),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        titleTextStyle: AppTypography.title(cs.onSurface),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: AppTypography.style(
            AppTypography.s16,
            weight: AppTypography.bold,
          ),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: AppTypography.style(
            AppTypography.s16,
            weight: AppTypography.bold,
          ),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTypography.style(
            AppTypography.s14,
            weight: AppTypography.bold,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: AppTypography.style(
          AppTypography.s14,
          color: cs.onSurfaceVariant,
        ),
        labelStyle: AppTypography.style(
          AppTypography.s14,
          color: cs.onSurfaceVariant,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.error),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.error, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
