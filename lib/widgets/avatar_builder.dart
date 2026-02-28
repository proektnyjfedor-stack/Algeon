/// Avatar Builder — конструктор персонажа
///
/// Bottom sheet с табами: фон, кожа, волосы, цвет волос, одежда, аксессуар, лицо

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'avatars.dart';

class AvatarBuilderSheet extends StatefulWidget {
  final AvatarData initialAvatar;
  final ValueChanged<AvatarData> onSave;

  const AvatarBuilderSheet({
    super.key,
    required this.initialAvatar,
    required this.onSave,
  });

  @override
  State<AvatarBuilderSheet> createState() => _AvatarBuilderSheetState();
}

class _AvatarBuilderSheetState extends State<AvatarBuilderSheet> {
  late AvatarData _avatar;
  int _selectedTab = 0;

  final _tabs = const [
    ('Фон', Icons.palette_outlined),
    ('Кожа', Icons.face_outlined),
    ('Причёска', Icons.content_cut_rounded),
    ('Цвет волос', Icons.brush_outlined),
    ('Одежда', Icons.checkroom_outlined),
    ('Аксессуар', Icons.auto_awesome_outlined),
    ('Лицо', Icons.emoji_emotions_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _avatar = widget.initialAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppThemeColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text('Конструктор персонажа', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary(context),
          )),
          const SizedBox(height: 16),

          // Preview
          AvatarWidget(avatarData: _avatar, size: 120, showBorder: true),
          const SizedBox(height: 16),

          // Tabs
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (int i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _selectedTab == i
                              ? AppColors.accent
                              : AppThemeColors.borderLight(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(_tabs[i].$2,
                                size: 16,
                                color: _selectedTab == i
                                    ? Colors.white
                                    : AppThemeColors.textSecondary(context)),
                            const SizedBox(width: 6),
                            Text(_tabs[i].$1, style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == i
                                  ? Colors.white
                                  : AppThemeColors.textSecondary(context),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildOptions(),
            ),
          ),

          // Presets + Save
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showPresets,
                    child: const Text('Готовые'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_avatar);
                      Navigator.pop(context);
                    },
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    switch (_selectedTab) {
      case 0: return _buildColorGrid(avatarBgColors, _avatar.bgColor, (c) => setState(() => _avatar = _avatar.copyWith(bgColor: c)));
      case 1: return _buildColorGrid(avatarSkinColors, _avatar.skinColor, (c) => setState(() => _avatar = _avatar.copyWith(skinColor: c)));
      case 2: return _buildHairStyleGrid();
      case 3: return _buildColorGrid(avatarHairColors, _avatar.hairColor, (c) => setState(() => _avatar = _avatar.copyWith(hairColor: c)));
      case 4: return _buildColorGrid(avatarShirtColors, _avatar.shirtColor, (c) => setState(() => _avatar = _avatar.copyWith(shirtColor: c)));
      case 5: return _buildAccessoryGrid();
      case 6: return _buildExpressionGrid();
      default: return const SizedBox();
    }
  }

  Widget _buildColorGrid(List<Color> colors, Color selected, ValueChanged<Color> onSelect) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12,
      ),
      itemCount: colors.length,
      itemBuilder: (_, i) {
        final isSelected = colors[i].toARGB32() == selected.toARGB32();
        return GestureDetector(
          onTap: () => onSelect(colors[i]),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildHairStyleGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9,
      ),
      itemCount: avatarHairStyles.length,
      itemBuilder: (_, i) {
        final style = avatarHairStyles[i];
        final isSelected = _avatar.hairStyle == style;
        final preview = _avatar.copyWith(hairStyle: style, id: 'preview');
        return GestureDetector(
          onTap: () => setState(() => _avatar = _avatar.copyWith(hairStyle: style)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(hairStyleNames[style] ?? style, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.accent : AppThemeColors.textSecondary(context),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9,
      ),
      itemCount: avatarAccessories.length,
      itemBuilder: (_, i) {
        final acc = avatarAccessories[i];
        final isSelected = _avatar.accessory == acc;
        final preview = _avatar.copyWith(accessory: acc, id: 'preview');
        return GestureDetector(
          onTap: () => setState(() => _avatar = _avatar.copyWith(accessory: acc)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(accessoryNames[acc] ?? acc, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.accent : AppThemeColors.textSecondary(context),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpressionGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9,
      ),
      itemCount: avatarExpressions.length,
      itemBuilder: (_, i) {
        final expr = avatarExpressions[i];
        final isSelected = _avatar.expression == expr;
        final preview = _avatar.copyWith(expression: expr, id: 'preview');
        return GestureDetector(
          onTap: () => setState(() => _avatar = _avatar.copyWith(expression: expr)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(expressionNames[expr] ?? expr, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.accent : AppThemeColors.textSecondary(context),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPresets() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Готовые персонажи', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            )),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10,
                ),
                itemCount: allAvatars.length,
                itemBuilder: (_, i) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _avatar = allAvatars[i].copyWith(id: 'custom'));
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AvatarWidget(avatarData: allAvatars[i], size: 60),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
