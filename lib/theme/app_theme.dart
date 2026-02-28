/// Тема Algeon — Минималистичный чистый дизайн
/// БЕЗ ГРАДИЕНТОВ — только чистые цвета

import 'package:flutter/material.dart';

/// Цвета — ТЁМНАЯ тема
class AppColors {
  AppColors._();

  // Основной акцент — синий (БЕЗ градиента)
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF1E3A5F);

  // Успех
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF132A1C);

  // Ошибка
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFF2A1313);

  // Оранжевый
  static const Color orange = Color(0xFFF97316);

  // Золотой
  static const Color gold = Color(0xFFEAB308);

  // Фиолетовый
  static const Color purple = Color(0xFF8B5CF6);

  // Розовый
  static const Color pink = Color(0xFFEC4899);

  // Фоны — чёрно-серые
  static const Color background = Color(0xFF111111);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF222222);

  // Текст
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);

  // Границы
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFF2A2A2A);

  // Disabled
  static const Color disabled = Color(0xFF333333);
  static const Color disabledText = Color(0xFF6B7280);
}

/// Цвета — СВЕТЛАЯ тема
class AppColorsLight {
  AppColorsLight._();

  static const Color accent = Color(0xFF2563EB);      // Более насыщенный синий
  static const Color accentLight = Color(0xFFDBEAFE);

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color orange = Color(0xFFEA580C);
  static const Color gold = Color(0xFFD97706);

  // Фиолетовый
  static const Color purple = Color(0xFF7C3AED);

  // Розовый
  static const Color pink = Color(0xFFDB2777);

  // Фоны — тёплый мягкий фон вместо белого
  static const Color background = Color(0xFFF0F4FF);  // нежно-голубой
  static const Color surface = Color(0xFFFFFFFF);     // белые карточки
  static const Color card = Color(0xFFF5F7FF);        // чуть голубоватый

  // Текст — высокий контраст
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textHint = Color(0xFF9CA3AF);

  // Границы
  static const Color border = Color(0xFFDDE3F0);
  static const Color borderLight = Color(0xFFEEF2FF);

  // Disabled
  static const Color disabled = Color(0xFFE2E8F0);
  static const Color disabledText = Color(0xFF94A3B8);
}

/// Адаптивные цвета
class AppThemeColors {
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.background
          : AppColorsLight.background;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : AppColorsLight.surface;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.card
          : AppColorsLight.card;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textPrimary
          : AppColorsLight.textPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textSecondary
          : AppColorsLight.textSecondary;

  static Color textHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textHint
          : AppColorsLight.textHint;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.border
          : AppColorsLight.border;

  static Color borderLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.borderLight
          : AppColorsLight.borderLight;

  static Color accentLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.accentLight
          : AppColorsLight.accentLight;

  static Color successLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.successLight
          : AppColorsLight.successLight;

  static Color errorLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.errorLight
          : AppColorsLight.errorLight;

  static Color disabled(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.disabled
          : AppColorsLight.disabled;

  static Color disabledText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.disabledText
          : AppColorsLight.disabledText;

  static Color orangeLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A1F13)
          : const Color(0xFFFFF7ED);

  static Color purpleLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1A2E)
          : const Color(0xFFF5F3FF);
}

/// Типографика
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

/// Радиусы
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
}

/// Тени (минимальные)
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? [] : [
      BoxShadow(
        color: const Color(0xFF2563EB).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> soft(BuildContext context) {
    return [];
  }
}

/// Тема Material — ТЁМНАЯ
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: AppColors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.borderLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

/// Тема Material — СВЕТЛАЯ
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColorsLight.accent,
      onPrimary: Colors.white,
      surface: AppColorsLight.surface,
      onSurface: AppColorsLight.textPrimary,
      error: AppColorsLight.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColorsLight.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.background,
      foregroundColor: AppColorsLight.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsLight.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: AppColorsLight.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsLight.accent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.body.copyWith(color: AppColorsLight.textHint),
    ),
    cardTheme: CardThemeData(
      color: AppColorsLight.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsLight.border,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColorsLight.accent,
      linearTrackColor: AppColorsLight.borderLight,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColorsLight.surface,
      selectedItemColor: AppColorsLight.accent,
      unselectedItemColor: AppColorsLight.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

ThemeData buildAppTheme() => buildDarkTheme();
