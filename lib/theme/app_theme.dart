/// Тема приложения MathPilot
/// Точная копия макета из Figma

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Цвета из макета
class AppColors {
  // Фон
  static const Color background = Color(0xFFF5F5F5);      // Светло-серый фон
  static const Color white = Color(0xFFFFFFFF);           // Белый
  static const Color surface = Color(0xFFFFFFFF);         // Белые карточки
  
  // Акцентный синий/фиолетовый (как на макете)
  static const Color accent = Color(0xFF6366F1);          // Индиго
  static const Color accentLight = Color(0xFFE0E7FF);     // Светлый индиго
  
  // Текст
  static const Color textPrimary = Color(0xFF1F2937);     // Почти чёрный
  static const Color textSecondary = Color(0xFF6B7280);   // Серый
  static const Color textHint = Color(0xFF9CA3AF);        // Светло-серый
  
  // Границы
  static const Color border = Color(0xFFE5E7EB);          // Серая граница
  static const Color borderDark = Color(0xFF374151);      // Тёмная граница
  
  // Статусы
  static const Color success = Color(0xFF10B981);         // Зелёный
  static const Color error = Color(0xFFEF4444);           // Красный
  
  // Текстовое поле с линиями
  static const Color inputBg = Color(0xFFEFF6FF);         // Светло-голубой фон
  static const Color inputLine = Color(0xFFBFDBFE);       // Голубые линии
  
  AppColors._();
}

/// Тема приложения
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      
      // Шрифт Inter (похож на макет)
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          // Большой заголовок (для задач типа "3*6?")
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
          // Заголовок
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          // Текст задачи
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          // Кнопки вариантов
          labelLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),
      
      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Нижняя навигация
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Текстовые поля
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),
    );
  }
  
  AppTheme._();
}
