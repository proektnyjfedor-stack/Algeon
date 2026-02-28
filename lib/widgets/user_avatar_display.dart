/// UserAvatarDisplay — автоматически выбирает тип отображения аватара:
///   • 'photo'  → фото из галереи (base64)
///   • 'custom' → конструктор аватара
///   • иначе    → предустановленный аватар по id

import 'dart:convert';
import 'package:flutter/material.dart';
import 'avatars.dart';
import '../services/progress_service.dart';

class UserAvatarDisplay extends StatelessWidget {
  final double size;
  final bool showBorder;
  final Color borderColor;

  const UserAvatarDisplay({
    super.key,
    this.size = 80,
    this.showBorder = false,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final avatarId = ProgressService.getAvatar();

    // ── Фото из галереи ──────────────────────────────────────
    if (avatarId == 'photo') {
      final photoB64 = ProgressService.getCustomPhoto();
      if (photoB64 != null) {
        return _PhotoFrame(
          size: size,
          showBorder: showBorder,
          borderColor: borderColor,
          child: Image.memory(
            base64Decode(photoB64),
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        );
      }
    }

    // ── Кастомный аватар из конструктора ─────────────────────
    if (avatarId == 'custom') {
      final customData = ProgressService.getCustomAvatar();
      if (customData != null) {
        final avatar = AvatarData.fromMap(customData);
        return AvatarWidget(avatarData: avatar, size: size, showBorder: showBorder);
      }
    }

    // ── Предустановленный аватар ─────────────────────────────
    return AvatarWidget(avatarId: avatarId, size: size, showBorder: showBorder);
  }
}

/// Рамка для фото (такой же скруглённый контейнер, как у AvatarWidget)
class _PhotoFrame extends StatelessWidget {
  final double size;
  final bool showBorder;
  final Color borderColor;
  final Widget child;

  const _PhotoFrame({
    required this.size,
    required this.showBorder,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.3;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: borderColor, width: 3)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
