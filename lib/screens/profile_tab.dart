import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/achievements_service.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/avatar_builder.dart';
import '../widgets/avatars.dart';
import '../widgets/user_avatar_display.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final ScrollController _scrollController;
  final ImagePicker _imagePicker = ImagePicker();
  static const Color _bluePrimary = Color(0xFF1D4ED8);
  static const Color _blueDeep = Color(0xFF1E40AF);
  static const Color _blueSoft = Color(0xFFEAF2FF);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: ProgressService.getUserName());
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Изменить имя'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: 'Например: Маша',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    final nextName = controller.text.trim();
    if (saved == true && nextName.isNotEmpty) {
      await ProgressService.setUserName(nextName);
      if (!mounted) return;
      setState(() {});
      _showSnack('Имя обновлено');
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await ProgressService.setCustomPhoto(base64Encode(bytes));
      if (!mounted) return;
      setState(() {});
      _showSnack('Фото аватарки обновлено');
    } catch (e) {
      _showSnack('Не удалось выбрать фото: $e');
    }
  }

  Future<void> _changeGrade() async {
    final current = ProgressService.getCurrentGrade();
    int selected = current;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Выбери класс',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(11, (i) {
                        final grade = i + 1;
                        final isSelected = selected == grade;
                        return ChoiceChip(
                          label: Text('$grade класс'),
                          selected: isSelected,
                          onSelected: (_) => setModalState(() => selected = grade),
                          selectedColor: _bluePrimary.withValues(alpha: 0.18),
                          labelStyle: TextStyle(
                            color: isSelected ? _blueDeep : AppThemeColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: isSelected ? _bluePrimary : AppThemeColors.border(context),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _bluePrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Сохранить класс'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      await ProgressService.setCurrentGrade(selected);
      if (!mounted) return;
      setState(() {});
      _showSnack('Класс обновлён');
    }
  }

  Future<void> _openAvatarBuilder() async {
    final savedCustom = ProgressService.getCustomAvatar();
    final initialAvatar = savedCustom != null
        ? AvatarData.fromMap(savedCustom)
        : defaultCustomAvatar;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AvatarBuilderSheet(
          initialAvatar: initialAvatar,
          onSave: (avatar) async {
            await ProgressService.setCustomAvatar(avatar.toMap());
            if (!mounted) return;
            setState(() {});
            _showSnack('Кастомная аватарка сохранена');
          },
        );
      },
    );
  }

  Future<void> _openPresetAvatars() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 420,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Text(
                'Выбери аватарку',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: allAvatars.length,
                  itemBuilder: (_, i) {
                    final avatar = allAvatars[i];
                    return GestureDetector(
                      onTap: () async {
                        await ProgressService.setAvatar(avatar.id);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        setState(() {});
                        _showSnack('Аватарка обновлена');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          AvatarWidget(avatarId: avatar.id, size: 56),
                          const SizedBox(height: 4),
                          Text(
                            avatar.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppThemeColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarActions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                _ActionTile(
                  icon: Icons.grid_view_rounded,
                  iconColor: AppColors.purple,
                  title: 'Выбрать готовую аватарку',
                  onTap: () {
                    Navigator.pop(context);
                    _openPresetAvatars();
                  },
                ),
                _ActionTile(
                  icon: Icons.auto_fix_high_rounded,
                  iconColor: AppColors.orange,
                  title: 'Открыть конструктор аватара',
                  onTap: () {
                    Navigator.pop(context);
                    _openAvatarBuilder();
                  },
                ),
                _ActionTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: AppColors.accent,
                  title: 'Загрузить фото из галереи',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhotoFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openBetaShop() async {
    final items = [
      ('skin_neon_blue', 'Скин: Неон Синий', 120),
      ('skin_gold_star', 'Скин: Золотая Звезда', 180),
      ('theme_space', 'Тема: Космос', 250),
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final coins = ProgressService.getCoins();
            final equipped = ProgressService.getEquippedBetaItem();
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Бета-магазин',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppThemeColors.accentLight(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$coins монет',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) {
                      final id = item.$1;
                      final title = item.$2;
                      final price = item.$3;
                      final owned = ProgressService.getBool('shop_item_$id');
                      final isEquipped = equipped == id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppThemeColors.border(context)),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(title)),
                              if (isEquipped)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppThemeColors.accentLight(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Экипировано',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(owned ? 'Куплено' : '$price монет'),
                          trailing: owned
                              ? ElevatedButton(
                                  onPressed: isEquipped
                                      ? null
                                      : () async {
                                          await ProgressService.setEquippedBetaItem(id);
                                          if (!mounted) return;
                                          setModalState(() {});
                                          setState(() {});
                                          _showSnack('Экипировано: $title');
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEquipped
                                        ? AppThemeColors.disabled(context)
                                        : _bluePrimary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(isEquipped ? 'Надето' : 'Надеть'),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Подтвердить покупку'),
                                        content: Text('Купить "$title" за $price монет?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Отмена'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Купить'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;

                                    final ok = await ProgressService.spendCoins(price);
                                    if (!ok) {
                                      _showSnack('Недостаточно монет');
                                      return;
                                    }
                                    await ProgressService.setBool('shop_item_$id', true);
                                    await ProgressService.setEquippedBetaItem(id);
                                    if (!mounted) return;
                                    setModalState(() {});
                                    setState(() {});
                                    _showSnack('Покупка: $title (экипировано)');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _bluePrimary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Купить'),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Это бета-магазин. Позже добавим реальные скины и эффекты.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ProgressService.getUserName();
    final currentGrade = ProgressService.getCurrentGrade();
    final solved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final streak = ProgressService.getStreakDays();
    final achievementsUnlocked = AchievementsService.getUnlockedCount();
    final achievementsTotal = AchievementsService.getTotalCount();
    final isGuest = AuthService.isAnonymous();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppThemeColors.background(context) : Colors.white;
    final cardBg = isDark ? AppThemeColors.surface(context) : Colors.white;
    final blueCard = isDark ? const Color(0xFF1E3A8A) : _bluePrimary;
    final blueCardAlt = isDark ? const Color(0xFF1D4ED8) : _blueDeep;
    final ratio = achievementsTotal == 0 ? 0.0 : achievementsUnlocked / achievementsTotal;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          primary: false,
          key: const ValueKey('profile_list'),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Профиль',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [blueCard, blueCardAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarActions,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      children: [
                        const UserAvatarDisplay(size: 92, showBorder: true),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _bluePrimary, width: 2),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: _bluePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _editName,
                        icon: const Icon(Icons.edit_outlined),
                        color: Colors.white,
                        tooltip: 'Изменить имя',
                      ),
                    ],
                  ),
                  Text(
                    '$currentGrade класс',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (isGuest) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Гостевой режим',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Статистика'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: 'Решено',
                  value: '$solved',
                  accent: Colors.white,
                  background: blueCard,
                ),
                _StatCard(
                  label: 'Точность',
                  value: '${accuracy.toStringAsFixed(0)}%',
                  accent: Colors.white,
                  background: blueCardAlt,
                ),
                _StatCard(
                  label: 'Серия',
                  value: '$streak дн.',
                  accent: Colors.white,
                  background: blueCard,
                ),
                _StatCard(
                  label: 'Награды',
                  value: '$achievementsUnlocked/$achievementsTotal',
                  accent: Colors.white,
                  background: blueCardAlt,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Прогресс по наградам'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'До следующего уровня',
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _bluePrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: ratio.clamp(0, 1),
                      backgroundColor: _blueSoft,
                      valueColor: const AlwaysStoppedAnimation<Color>(_bluePrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Быстрые действия'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  title: 'Изменить имя',
                  icon: Icons.badge_outlined,
                  color: _bluePrimary,
                  onTap: _editName,
                ),
                _QuickActionButton(
                  title: 'Сменить аватар',
                  icon: Icons.face_rounded,
                  color: _bluePrimary,
                  onTap: _showAvatarActions,
                ),
                _QuickActionButton(
                  title: 'Фото из галереи',
                  icon: Icons.photo_library_rounded,
                  color: _bluePrimary,
                  onTap: _pickPhotoFromGallery,
                ),
                _QuickActionButton(
                  title: 'Сменить класс',
                  icon: Icons.school_rounded,
                  color: _bluePrimary,
                  onTap: _changeGrade,
                ),
                _QuickActionButton(
                  title: 'Бета-магазин',
                  icon: Icons.storefront_rounded,
                  color: _bluePrimary,
                  onTap: _openBetaShop,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Настройки'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemeColors.border(context)),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    title: 'Имя',
                    subtitle: userName,
                    icon: Icons.person_outline_rounded,
                    iconColor: _bluePrimary,
                    trailing: TextButton(
                      onPressed: _editName,
                      child: const Text('Изменить'),
                    ),
                  ),
                  const _DividerLine(),
                  _SettingsTile(
                    title: 'Аватарка',
                    subtitle: 'Выбрать из готовых, конструктор или фото',
                    icon: Icons.face_rounded,
                    iconColor: _bluePrimary,
                    trailing: TextButton(
                      onPressed: _showAvatarActions,
                      child: const Text('Открыть'),
                    ),
                  ),
                  const _DividerLine(),
                  _SettingsTile(
                    title: 'Класс',
                    subtitle: '$currentGrade класс',
                    icon: Icons.school_outlined,
                    iconColor: _bluePrimary,
                    trailing: TextButton(
                      onPressed: _changeGrade,
                      child: const Text('Изменить'),
                    ),
                  ),
                  const _DividerLine(),
                  SwitchListTile(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    title: Text(
                      'Тёмная тема',
                      style: TextStyle(
                        color: AppThemeColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isDark ? 'Включена' : 'Выключена',
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: _bluePrimary,
                    ),
                    activeThumbColor: _bluePrimary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppThemeColors.textPrimary(context),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color background;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _ProfileTabState._bluePrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: AppThemeColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppThemeColors.textSecondary(context),
        ),
      ),
      trailing: trailing,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: AppThemeColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppThemeColors.border(context),
    );
  }
}
