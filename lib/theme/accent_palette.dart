import 'package:flutter/material.dart';

class AccentPalette {
  static const defaultColor = Color(0xFF2563EB);
  static const presets = <String, Color>{
    'Синий': defaultColor,
    'Зелёный': Color(0xFF16A34A),
    'Бирюзовый': Color(0xFF0891B2),
    'Фиолетовый': Color(0xFF7C3AED),
    'Розовый': Color(0xFFDB2777),
    'Оранжевый': Color(0xFFEA580C),
    'Графит': Color(0xFF64748B),
  };
  static Color primary(Color seed, Brightness brightness) {
    // Keep the accent readable on either background and on white buttons.
    final hsl = HSLColor.fromColor(seed);
    var result = seed;
    final minLuminance = brightness == Brightness.dark ? 0.12 : 0.0;
    var lightness = hsl.lightness;
    for (var i = 0; i < 100 && result.computeLuminance() > 0.183; i++) {
      lightness = (lightness - 0.01).clamp(0.0, 1.0);
      result = hsl.withLightness(lightness).toColor();
    }
    for (var i = 0; i < 100 && result.computeLuminance() < minLuminance; i++) {
      lightness = (lightness + 0.005).clamp(0.0, 1.0);
      result = hsl.withLightness(lightness).toColor();
    }
    return result;
  }

  static Color? parseHex(String value) {
    final text = value.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(text)) return null;
    return Color(0xFF000000 | int.parse(text, radix: 16));
  }

  static String hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
