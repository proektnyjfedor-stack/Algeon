/// Аватарки с полной кастомизацией
///
/// CustomPaint персонажи: волосы, кожа, одежда, аксессуары, выражение лица, фон

import 'dart:convert';
import 'package:flutter/material.dart';

// === Варианты для каждой категории ===

const List<Color> avatarBgColors = [
  Color(0xFFDDF4FF), Color(0xFFFFE0F0), Color(0xFFD7FFB8), Color(0xFFF3E8FF),
  Color(0xFFFFF4E5), Color(0xFFFFE0E0), Color(0xFFE8E8E8), Color(0xFFFFF9E6),
];

const List<Color> avatarSkinColors = [
  Color(0xFFFFDBAC), Color(0xFFF5D0A9), Color(0xFFE8B98A),
  Color(0xFFC68642), Color(0xFF8D5524), Color(0xFFFFE0BD),
];

const List<Color> avatarHairColors = [
  Color(0xFF1A1A1A), Color(0xFF5C4033), Color(0xFF8B4513), Color(0xFF2C1810),
  Color(0xFFD4A03A), Color(0xFFC0392B), Color(0xFF607D8B), Color(0xFFE8E8E8),
];

const List<Color> avatarShirtColors = [
  Color(0xFF1CB0F6), Color(0xFFFF6B9D), Color(0xFF58CC02), Color(0xFFCE82FF),
  Color(0xFFFF9600), Color(0xFFFF4B4B), Color(0xFF3C3C3C), Color(0xFF1ABC9C),
];

const List<String> avatarHairStyles = [
  'boy_short', 'boy_spiky', 'girl_long', 'girl_pigtails', 'girl_short', 'bald',
];

const Map<String, String> hairStyleNames = {
  'boy_short': 'Короткие',
  'boy_spiky': 'Торчком',
  'girl_long': 'Длинные',
  'girl_pigtails': 'Хвостики',
  'girl_short': 'Каре',
  'bald': 'Нет',
};

const List<String> avatarAccessories = [
  'none', 'glasses', 'bow', 'hat', 'headband', 'crown',
];

const Map<String, String> accessoryNames = {
  'none': 'Нет',
  'glasses': 'Очки',
  'bow': 'Бант',
  'hat': 'Шляпа',
  'headband': 'Повязка',
  'crown': 'Корона',
};

const List<String> avatarExpressions = [
  'smile', 'grin', 'wink', 'surprised', 'cool',
];

const Map<String, String> expressionNames = {
  'smile': 'Улыбка',
  'grin': 'Ухмылка',
  'wink': 'Подмиг.',
  'surprised': 'Удивл.',
  'cool': 'Крутой',
};

/// Данные аватарки
class AvatarData {
  final String id;
  final String name;
  final Color bgColor;
  final Color skinColor;
  final String hairStyle;
  final Color hairColor;
  final Color shirtColor;
  final String accessory;
  final String expression;

  const AvatarData({
    required this.id,
    required this.name,
    required this.bgColor,
    required this.skinColor,
    this.hairStyle = 'boy_short',
    required this.hairColor,
    required this.shirtColor,
    this.accessory = 'none',
    this.expression = 'smile',
  });

  bool get isBoy => hairStyle.startsWith('boy') || hairStyle == 'bald';

  AvatarData copyWith({
    String? id,
    String? name,
    Color? bgColor,
    Color? skinColor,
    String? hairStyle,
    Color? hairColor,
    Color? shirtColor,
    String? accessory,
    String? expression,
  }) {
    return AvatarData(
      id: id ?? this.id,
      name: name ?? this.name,
      bgColor: bgColor ?? this.bgColor,
      skinColor: skinColor ?? this.skinColor,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      shirtColor: shirtColor ?? this.shirtColor,
      accessory: accessory ?? this.accessory,
      expression: expression ?? this.expression,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'bgColor': bgColor.toARGB32(),
        'skinColor': skinColor.toARGB32(),
        'hairStyle': hairStyle,
        'hairColor': hairColor.toARGB32(),
        'shirtColor': shirtColor.toARGB32(),
        'accessory': accessory,
        'expression': expression,
      };

  String toJson() => jsonEncode(toMap());

  factory AvatarData.fromMap(Map<String, dynamic> map) {
    return AvatarData(
      id: map['id'] as String? ?? 'custom',
      name: map['name'] as String? ?? 'Персонаж',
      bgColor: Color(map['bgColor'] as int? ?? 0xFFDDF4FF),
      skinColor: Color(map['skinColor'] as int? ?? 0xFFFFDBAC),
      hairStyle: map['hairStyle'] as String? ?? 'boy_short',
      hairColor: Color(map['hairColor'] as int? ?? 0xFF5C4033),
      shirtColor: Color(map['shirtColor'] as int? ?? 0xFF1CB0F6),
      accessory: map['accessory'] as String? ?? 'none',
      expression: map['expression'] as String? ?? 'smile',
    );
  }

  factory AvatarData.fromJson(String json) =>
      AvatarData.fromMap(jsonDecode(json) as Map<String, dynamic>);
}

/// Пресетные аватарки
const List<AvatarData> allAvatars = [
  AvatarData(id: 'boy_blue', name: 'Артём', bgColor: Color(0xFFDDF4FF), skinColor: Color(0xFFFFDBAC), hairStyle: 'boy_short', hairColor: Color(0xFF5C4033), shirtColor: Color(0xFF1CB0F6)),
  AvatarData(id: 'girl_pink', name: 'Алиса', bgColor: Color(0xFFFFE0F0), skinColor: Color(0xFFFFDBAC), hairStyle: 'girl_long', hairColor: Color(0xFF8B4513), shirtColor: Color(0xFFFF6B9D), accessory: 'bow'),
  AvatarData(id: 'boy_green', name: 'Максим', bgColor: Color(0xFFD7FFB8), skinColor: Color(0xFFF5D0A9), hairStyle: 'boy_short', hairColor: Color(0xFF2C1810), shirtColor: Color(0xFF58CC02), accessory: 'glasses'),
  AvatarData(id: 'girl_purple', name: 'Мария', bgColor: Color(0xFFF3E8FF), skinColor: Color(0xFFFFDBAC), hairStyle: 'girl_short', hairColor: Color(0xFF1A1A2E), shirtColor: Color(0xFFCE82FF)),
  AvatarData(id: 'boy_orange', name: 'Дима', bgColor: Color(0xFFFFF4E5), skinColor: Color(0xFFE8B98A), hairStyle: 'boy_spiky', hairColor: Color(0xFFD4A03A), shirtColor: Color(0xFFFF9600), accessory: 'hat'),
  AvatarData(id: 'girl_red', name: 'София', bgColor: Color(0xFFFFE0E0), skinColor: Color(0xFFF5D0A9), hairStyle: 'girl_pigtails', hairColor: Color(0xFFC0392B), shirtColor: Color(0xFFFF4B4B), accessory: 'bow'),
  AvatarData(id: 'boy_dark', name: 'Кирилл', bgColor: Color(0xFFE8E8E8), skinColor: Color(0xFFC68642), hairStyle: 'boy_short', hairColor: Color(0xFF1A1A1A), shirtColor: Color(0xFF3C3C3C)),
  AvatarData(id: 'girl_teal', name: 'Настя', bgColor: Color(0xFFD5F5F5), skinColor: Color(0xFFFFDBAC), hairStyle: 'girl_long', hairColor: Color(0xFF5C4033), shirtColor: Color(0xFF1ABC9C), accessory: 'glasses'),
  AvatarData(id: 'robot', name: 'Робот', bgColor: Color(0xFFE8E8E8), skinColor: Color(0xFFB0BEC5), hairStyle: 'bald', hairColor: Color(0xFF607D8B), shirtColor: Color(0xFF1CB0F6)),
  AvatarData(id: 'cat', name: 'Котик', bgColor: Color(0xFFFFF4E5), skinColor: Color(0xFFFF9600), hairStyle: 'bald', hairColor: Color(0xFFE67E22), shirtColor: Color(0xFFFF9600)),
];

/// Дефолтный аватар для конструктора
AvatarData defaultCustomAvatar = const AvatarData(
  id: 'custom',
  name: 'Персонаж',
  bgColor: Color(0xFFDDF4FF),
  skinColor: Color(0xFFFFDBAC),
  hairStyle: 'boy_short',
  hairColor: Color(0xFF5C4033),
  shirtColor: Color(0xFF1CB0F6),
  accessory: 'none',
  expression: 'smile',
);

/// Виджет аватарки
class AvatarWidget extends StatelessWidget {
  final String? avatarId;
  final AvatarData? avatarData;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    this.avatarId,
    this.avatarData,
    this.size = 80,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarData ??
        allAvatars.firstWhere(
          (a) => a.id == avatarId,
          orElse: () => allAvatars[0],
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatar.bgColor,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: showBorder
            ? Border.all(color: Colors.white, width: 3)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: CustomPaint(
          painter: _AvatarPainter(avatar: avatar),
          size: Size(size, size),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  final AvatarData avatar;
  _AvatarPainter({required this.avatar});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    if (avatar.id == 'robot') { _paintRobot(canvas, size); return; }
    if (avatar.id == 'cat') { _paintCat(canvas, size); return; }

    final cx = s / 2;
    final skinPaint = Paint()..color = avatar.skinColor;
    final hairPaint = Paint()..color = avatar.hairColor;

    // --- Тело (рубашка) ---
    canvas.drawOval(
      Rect.fromLTWH(s * 0.15, s * 0.65, s * 0.7, s * 0.45),
      Paint()..color = avatar.shirtColor,
    );

    // --- Шея ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - s * 0.08, s * 0.55, s * 0.16, s * 0.15),
        Radius.circular(s * 0.04),
      ),
      skinPaint,
    );

    // --- Голова ---
    canvas.drawOval(
      Rect.fromLTWH(s * 0.2, s * 0.12, s * 0.6, s * 0.5),
      skinPaint,
    );

    // --- Волосы ---
    _paintHair(canvas, s, cx, hairPaint);

    // --- Глаза и выражение ---
    _paintExpression(canvas, s, cx);

    // --- Щёчки ---
    final blushPaint = Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromLTWH(cx - s * 0.25, s * 0.42, s * 0.1, s * 0.07), blushPaint);
    canvas.drawOval(Rect.fromLTWH(cx + s * 0.15, s * 0.42, s * 0.1, s * 0.07), blushPaint);

    // --- Аксессуары ---
    _paintAccessory(canvas, s, cx);
  }

  void _paintHair(Canvas canvas, double s, double cx, Paint hairPaint) {
    switch (avatar.hairStyle) {
      case 'boy_short':
        canvas.drawArc(Rect.fromLTWH(s * 0.18, s * 0.08, s * 0.64, s * 0.4), 3.14, 3.14, true, hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.18, s * 0.15, s * 0.12, s * 0.18), Radius.circular(s * 0.04)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.7, s * 0.15, s * 0.12, s * 0.18), Radius.circular(s * 0.04)), hairPaint);
        break;

      case 'boy_spiky':
        // Основа волос
        canvas.drawArc(Rect.fromLTWH(s * 0.18, s * 0.1, s * 0.64, s * 0.32), 3.14, 3.14, true, hairPaint);
        // Волосы торчком (мягкие закруглённые)
        final spikes = [
          Offset(s * 0.28, s * 0.05),
          Offset(s * 0.40, s * 0.02),
          Offset(s * 0.50, s * 0.0),
          Offset(s * 0.60, s * 0.02),
          Offset(s * 0.72, s * 0.05),
        ];
        for (final spike in spikes) {
          canvas.drawOval(
            Rect.fromCenter(center: spike, width: s * 0.12, height: s * 0.16),
            hairPaint,
          );
        }
        // Бока
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.18, s * 0.16, s * 0.1, s * 0.14), Radius.circular(s * 0.04)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.72, s * 0.16, s * 0.1, s * 0.14), Radius.circular(s * 0.04)), hairPaint);
        break;

      case 'girl_long':
        canvas.drawArc(Rect.fromLTWH(s * 0.16, s * 0.06, s * 0.68, s * 0.45), 3.14, 3.14, true, hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.14, s * 0.15, s * 0.14, s * 0.45), Radius.circular(s * 0.06)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.72, s * 0.15, s * 0.14, s * 0.45), Radius.circular(s * 0.06)), hairPaint);
        break;

      case 'girl_pigtails':
        canvas.drawArc(Rect.fromLTWH(s * 0.16, s * 0.06, s * 0.68, s * 0.45), 3.14, 3.14, true, hairPaint);
        // Два хвостика
        canvas.drawOval(Rect.fromLTWH(s * 0.04, s * 0.15, s * 0.2, s * 0.25), hairPaint);
        canvas.drawOval(Rect.fromLTWH(s * 0.76, s * 0.15, s * 0.2, s * 0.25), hairPaint);
        // Резинки
        canvas.drawCircle(Offset(s * 0.16, s * 0.2), s * 0.03, Paint()..color = avatar.shirtColor);
        canvas.drawCircle(Offset(s * 0.84, s * 0.2), s * 0.03, Paint()..color = avatar.shirtColor);
        break;

      case 'girl_short':
        canvas.drawArc(Rect.fromLTWH(s * 0.16, s * 0.06, s * 0.68, s * 0.45), 3.14, 3.14, true, hairPaint);
        // Каре — чуть ниже ушей
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.14, s * 0.15, s * 0.14, s * 0.3), Radius.circular(s * 0.06)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.72, s * 0.15, s * 0.14, s * 0.3), Radius.circular(s * 0.06)), hairPaint);
        break;

      case 'bald':
        // Без волос
        break;
    }
  }

  void _paintExpression(Canvas canvas, double s, double cx) {
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = const Color(0xFF2C1810);
    final eyeShine = Paint()..color = Colors.white;

    final isCool = avatar.expression == 'cool';
    final isWink = avatar.expression == 'wink';

    if (!isCool) {
      // Левый глаз
      canvas.drawOval(Rect.fromLTWH(cx - s * 0.18, s * 0.3, s * 0.14, s * 0.14), eyeWhite);
      canvas.drawOval(Rect.fromLTWH(cx - s * 0.15, s * 0.32, s * 0.09, s * 0.1), eyePupil);
      canvas.drawCircle(Offset(cx - s * 0.12, s * 0.34), s * 0.02, eyeShine);

      // Правый глаз (или подмигивание)
      if (isWink) {
        // Закрытый глаз — дуга
        final winkPaint = Paint()
          ..color = const Color(0xFF2C1810)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.025
          ..strokeCap = StrokeCap.round;
        final winkPath = Path()
          ..moveTo(cx + s * 0.05, s * 0.37)
          ..quadraticBezierTo(cx + s * 0.11, s * 0.32, cx + s * 0.17, s * 0.37);
        canvas.drawPath(winkPath, winkPaint);
      } else {
        canvas.drawOval(Rect.fromLTWH(cx + s * 0.04, s * 0.3, s * 0.14, s * 0.14), eyeWhite);
        canvas.drawOval(Rect.fromLTWH(cx + s * 0.06, s * 0.32, s * 0.09, s * 0.1), eyePupil);
        canvas.drawCircle(Offset(cx + s * 0.1, s * 0.34), s * 0.02, eyeShine);
      }

      // Surprised — приподнятые брови
      if (avatar.expression == 'surprised') {
        final browPaint = Paint()
          ..color = avatar.hairColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.02
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx - s * 0.17, s * 0.26), Offset(cx - s * 0.07, s * 0.24), browPaint);
        canvas.drawLine(Offset(cx + s * 0.07, s * 0.24), Offset(cx + s * 0.17, s * 0.26), browPaint);
      }
    } else {
      // Cool — солнечные очки
      final glassPaint = Paint()..color = const Color(0xFF1A1A1A);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.22, s * 0.28, s * 0.2, s * 0.14), Radius.circular(s * 0.04)), glassPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s * 0.02, s * 0.28, s * 0.2, s * 0.14), Radius.circular(s * 0.04)), glassPaint);
      canvas.drawLine(Offset(cx - s * 0.02, s * 0.35), Offset(cx + s * 0.02, s * 0.35), Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = s * 0.02);
      // Блик на очках
      final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.18, s * 0.3, s * 0.06, s * 0.04), Radius.circular(s * 0.02)), shinePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s * 0.06, s * 0.3, s * 0.06, s * 0.04), Radius.circular(s * 0.02)), shinePaint);
    }

    // --- Рот ---
    _paintMouth(canvas, s, cx);
  }

  void _paintMouth(Canvas canvas, double s, double cx) {
    switch (avatar.expression) {
      case 'smile':
        final smilePaint = Paint()
          ..color = const Color(0xFFE74C3C)..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.025..strokeCap = StrokeCap.round;
        final path = Path()
          ..moveTo(cx - s * 0.1, s * 0.48)
          ..quadraticBezierTo(cx, s * 0.56, cx + s * 0.1, s * 0.48);
        canvas.drawPath(path, smilePaint);
        break;

      case 'grin':
        // Широкая улыбка с зубами
        final mouthBg = Paint()..color = const Color(0xFFE74C3C);
        final path = Path()
          ..moveTo(cx - s * 0.12, s * 0.47)
          ..quadraticBezierTo(cx, s * 0.58, cx + s * 0.12, s * 0.47)
          ..close();
        canvas.drawPath(path, mouthBg);
        // Зубы
        canvas.drawRect(Rect.fromLTWH(cx - s * 0.08, s * 0.47, s * 0.16, s * 0.03), Paint()..color = Colors.white);
        break;

      case 'wink':
      case 'cool':
        // Лёгкая улыбка
        final smilePaint = Paint()
          ..color = const Color(0xFFE74C3C)..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.025..strokeCap = StrokeCap.round;
        final path = Path()
          ..moveTo(cx - s * 0.08, s * 0.49)
          ..quadraticBezierTo(cx, s * 0.55, cx + s * 0.08, s * 0.49);
        canvas.drawPath(path, smilePaint);
        break;

      case 'surprised':
        // Кружок "О"
        canvas.drawOval(
          Rect.fromLTWH(cx - s * 0.05, s * 0.47, s * 0.1, s * 0.08),
          Paint()..color = const Color(0xFFE74C3C),
        );
        break;
    }
  }

  void _paintAccessory(Canvas canvas, double s, double cx) {
    switch (avatar.accessory) {
      case 'glasses':
        final glassPaint = Paint()
          ..color = const Color(0xFF3C3C3C)..style = PaintingStyle.stroke..strokeWidth = s * 0.02;
        canvas.drawOval(Rect.fromLTWH(cx - s * 0.2, s * 0.28, s * 0.18, s * 0.16), glassPaint);
        canvas.drawOval(Rect.fromLTWH(cx + s * 0.02, s * 0.28, s * 0.18, s * 0.16), glassPaint);
        canvas.drawLine(Offset(cx - s * 0.02, s * 0.36), Offset(cx + s * 0.02, s * 0.36), glassPaint);
        break;

      case 'bow':
        final bowPaint = Paint()..color = const Color(0xFFFF6B9D);
        canvas.drawOval(Rect.fromLTWH(cx + s * 0.08, s * 0.1, s * 0.15, s * 0.1), bowPaint);
        canvas.drawOval(Rect.fromLTWH(cx + s * 0.2, s * 0.1, s * 0.15, s * 0.1), bowPaint);
        canvas.drawCircle(Offset(cx + s * 0.2, s * 0.15), s * 0.03, Paint()..color = const Color(0xFFFF4B8A));
        break;

      case 'hat':
        final hatPaint = Paint()..color = avatar.shirtColor;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.12, s * 0.14, s * 0.76, s * 0.06), Radius.circular(s * 0.03)), hatPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.22, s * 0.0, s * 0.56, s * 0.18), Radius.circular(s * 0.06)), hatPaint);
        break;

      case 'headband':
        final bandPaint = Paint()..color = avatar.shirtColor..strokeWidth = s * 0.04..style = PaintingStyle.stroke;
        canvas.drawArc(Rect.fromLTWH(s * 0.2, s * 0.1, s * 0.6, s * 0.3), 3.14, 3.14, false, bandPaint);
        break;

      case 'crown':
        final crownPaint = Paint()..color = const Color(0xFFFFD700);
        final crownPath = Path()
          ..moveTo(s * 0.22, s * 0.16)
          ..lineTo(s * 0.28, s * 0.04)
          ..lineTo(s * 0.38, s * 0.12)
          ..lineTo(s * 0.5, s * 0.02)
          ..lineTo(s * 0.62, s * 0.12)
          ..lineTo(s * 0.72, s * 0.04)
          ..lineTo(s * 0.78, s * 0.16)
          ..close();
        canvas.drawPath(crownPath, crownPaint);
        // Камни
        canvas.drawCircle(Offset(s * 0.5, s * 0.1), s * 0.02, Paint()..color = const Color(0xFFFF4B4B));
        break;

      case 'none':
        break;
    }
  }

  void _paintRobot(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.2, s * 0.6, s * 0.6, s * 0.35), Radius.circular(s * 0.08)), Paint()..color = avatar.shirtColor);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.2, s * 0.15, s * 0.6, s * 0.45), Radius.circular(s * 0.1)), Paint()..color = avatar.skinColor);
    canvas.drawLine(Offset(cx, s * 0.15), Offset(cx, s * 0.05), Paint()..color = avatar.hairColor..strokeWidth = s * 0.025);
    canvas.drawCircle(Offset(cx, s * 0.05), s * 0.03, Paint()..color = const Color(0xFF1CB0F6));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.2, s * 0.28, s * 0.15, s * 0.12), Radius.circular(s * 0.03)), Paint()..color = const Color(0xFF1CB0F6));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s * 0.05, s * 0.28, s * 0.15, s * 0.12), Radius.circular(s * 0.03)), Paint()..color = const Color(0xFF1CB0F6));
    canvas.drawCircle(Offset(cx - s * 0.12, s * 0.34), s * 0.03, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + s * 0.12, s * 0.34), s * 0.03, Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s * 0.1, s * 0.46, s * 0.2, s * 0.06), Radius.circular(s * 0.03)), Paint()..color = avatar.hairColor);
  }

  void _paintCat(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final catPaint = Paint()..color = avatar.skinColor;
    canvas.drawOval(Rect.fromLTWH(s * 0.2, s * 0.55, s * 0.6, s * 0.4), catPaint);
    canvas.drawOval(Rect.fromLTWH(s * 0.2, s * 0.2, s * 0.6, s * 0.45), catPaint);
    // Уши
    final ear1 = Path()..moveTo(s * 0.22, s * 0.28)..lineTo(s * 0.18, s * 0.05)..lineTo(s * 0.4, s * 0.2)..close();
    final ear2 = Path()..moveTo(s * 0.78, s * 0.28)..lineTo(s * 0.82, s * 0.05)..lineTo(s * 0.6, s * 0.2)..close();
    canvas.drawPath(ear1, catPaint);
    canvas.drawPath(ear2, catPaint);
    final innerEarPaint = Paint()..color = const Color(0xFFFFB3B3);
    final ie1 = Path()..moveTo(s * 0.25, s * 0.28)..lineTo(s * 0.22, s * 0.12)..lineTo(s * 0.37, s * 0.22)..close();
    final ie2 = Path()..moveTo(s * 0.75, s * 0.28)..lineTo(s * 0.78, s * 0.12)..lineTo(s * 0.63, s * 0.22)..close();
    canvas.drawPath(ie1, innerEarPaint);
    canvas.drawPath(ie2, innerEarPaint);
    // Глаза
    canvas.drawOval(Rect.fromLTWH(cx - s * 0.18, s * 0.32, s * 0.14, s * 0.14), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromLTWH(cx + s * 0.04, s * 0.32, s * 0.14, s * 0.14), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromLTWH(cx - s * 0.13, s * 0.34, s * 0.05, s * 0.1), Paint()..color = const Color(0xFF2C1810));
    canvas.drawOval(Rect.fromLTWH(cx + s * 0.08, s * 0.34, s * 0.05, s * 0.1), Paint()..color = const Color(0xFF2C1810));
    // Нос
    final nose = Path()..moveTo(cx, s * 0.46)..lineTo(cx - s * 0.03, s * 0.5)..lineTo(cx + s * 0.03, s * 0.5)..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFFF6B9D));
    // Усы
    final wp = Paint()..color = avatar.hairColor.withValues(alpha: 0.5)..strokeWidth = s * 0.012..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - s * 0.08, s * 0.48), Offset(s * 0.08, s * 0.45), wp);
    canvas.drawLine(Offset(cx - s * 0.08, s * 0.5), Offset(s * 0.08, s * 0.52), wp);
    canvas.drawLine(Offset(cx + s * 0.08, s * 0.48), Offset(s * 0.92, s * 0.45), wp);
    canvas.drawLine(Offset(cx + s * 0.08, s * 0.5), Offset(s * 0.92, s * 0.52), wp);
    // Улыбка
    final sp = Paint()..color = avatar.hairColor.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = s * 0.015..strokeCap = StrokeCap.round;
    final smile = Path()..moveTo(cx - s * 0.06, s * 0.52)..quadraticBezierTo(cx, s * 0.58, cx + s * 0.06, s * 0.52);
    canvas.drawPath(smile, sp);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      avatar.toJson() != oldDelegate.avatar.toJson();
}
