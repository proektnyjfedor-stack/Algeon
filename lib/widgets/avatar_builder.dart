/// Avatar Builder — конструктор персонажа
///
/// Bottom sheet с табами: фон, кожа, волосы, цвет волос, одежда, аксессуар, лицо
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import 'avatars.dart';

class AvatarBuilderSheet extends StatefulWidget {
  const AvatarBuilderSheet({
    super.key,
    required this.initialAvatar,
    required this.onSave,
  });
  final AvatarData initialAvatar;
  final ValueChanged<AvatarData> onSave;

  @override
  State<AvatarBuilderSheet> createState() => _AvatarBuilderSheetState();
}

class _AvatarBuilderSheetState extends State<AvatarBuilderSheet> {
  late AvatarData _avatar;
  int _selectedTab = 0;

  late List<(String, IconData)> _tabs;

  @override
  void initState() {
    super.initState();
    _avatar = widget.initialAvatar;
    _tabs = const [
      ('onboarding.background', Icons.palette_outlined),
      ('onboarding.skin', Icons.face_outlined),
      ('onboarding.hair', Icons.content_cut_rounded),
      ('onboarding.hairColor', Icons.brush_outlined),
      ('onboarding.clothes', Icons.checkroom_outlined),
      ('onboarding.accessory', Icons.auto_awesome_outlined),
      ('onboarding.expression', Icons.emoji_emotions_outlined),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageService>().t;
    final media = MediaQuery.of(context);
    final isLandscape = media.size.width > media.size.height;
    final sheetHeight = media.size.height * (isLandscape ? 0.9 : 0.78);

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppThemeColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            t('profile.openAvatarBuilder'),
            style: TextStyle(
              fontSize: isLandscape ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          SizedBox(height: isLandscape ? 12 : 16),

          // Preview
          AvatarWidget(
            avatarData: _avatar,
            size: isLandscape ? 96 : 120,
            showBorder: true,
          ),
          SizedBox(height: isLandscape ? 10 : 16),

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
                              ? Theme.of(context).colorScheme.primary
                              : AppThemeColors.borderLight(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _tabs[i].$2,
                              size: 16,
                              color: _selectedTab == i
                                  ? Colors.white
                                  : AppThemeColors.textSecondary(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t(_tabs[i].$1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedTab == i
                                    ? Colors.white
                                    : AppThemeColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: isLandscape ? 10 : 16),

          // Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildOptions(),
            ),
          ),

          // Save
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_avatar);
                  Navigator.pop(context);
                },
                child: Text(t('common.save')),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    switch (_selectedTab) {
      case 0:
        return _buildColorGrid(
          avatarBgColors,
          _avatar.bgColor,
          (c) => setState(() => _avatar = _avatar.copyWith(bgColor: c)),
        );
      case 1:
        return _buildColorGrid(
          avatarSkinColors,
          _avatar.skinColor,
          (c) => setState(() => _avatar = _avatar.copyWith(skinColor: c)),
        );
      case 2:
        return _buildHairStyleGrid();
      case 3:
        return _buildColorGrid(
          avatarHairColors,
          _avatar.hairColor,
          (c) => setState(() => _avatar = _avatar.copyWith(hairColor: c)),
        );
      case 4:
        return _buildColorGrid(
          avatarShirtColors,
          _avatar.shirtColor,
          (c) => setState(() => _avatar = _avatar.copyWith(shirtColor: c)),
        );
      case 5:
        return _buildAccessoryGrid();
      case 6:
        return _buildExpressionGrid();
      default:
        return const SizedBox();
    }
  }

  Widget _buildColorGrid(
    List<Color> colors,
    Color selected,
    ValueChanged<Color> onSelect,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
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
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
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
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: avatarHairStyles.length,
      itemBuilder: (_, i) {
        final style = avatarHairStyles[i];
        final isSelected = _avatar.hairStyle == style;
        final preview = _avatar.copyWith(hairStyle: style, id: 'preview');
        return GestureDetector(
          onTap: () =>
              setState(() => _avatar = _avatar.copyWith(hairStyle: style)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(
                  hairStyleNames[style] ?? style,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppThemeColors.textSecondary(context),
                  ),
                ),
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
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: avatarAccessories.length,
      itemBuilder: (_, i) {
        final acc = avatarAccessories[i];
        final isSelected = _avatar.accessory == acc;
        final preview = _avatar.copyWith(accessory: acc, id: 'preview');
        return GestureDetector(
          onTap: () =>
              setState(() => _avatar = _avatar.copyWith(accessory: acc)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(
                  accessoryNames[acc] ?? acc,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppThemeColors.textSecondary(context),
                  ),
                ),
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
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: avatarExpressions.length,
      itemBuilder: (_, i) {
        final expr = avatarExpressions[i];
        final isSelected = _avatar.expression == expr;
        final preview = _avatar.copyWith(expression: expr, id: 'preview');
        return GestureDetector(
          onTap: () =>
              setState(() => _avatar = _avatar.copyWith(expression: expr)),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarWidget(avatarData: preview, size: 56),
                const SizedBox(height: 6),
                Text(
                  expressionNames[expr] ?? expr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppThemeColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
