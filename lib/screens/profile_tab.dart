import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../router/app_router.dart';
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
  static const Color _bluePrimary = Color(0xFF3B82F6);
  static const Color _blueDeep = Color(0xFF2563EB);
  static const Color _blueSoft = Color(0xFFF0F7FF);

  ({Color primary, Color secondary, Color soft, String? label}) _equippedPalette() {
    final unlocked = AchievementsService.getUnlockedCount();
    if (unlocked >= 14) {
      return (
        primary: const Color(0xFF6D28D9),
        secondary: const Color(0xFF4C1D95),
        soft: const Color(0xFFF3E8FF),
        label: 'Фон: Аметист (14 наград)',
      );
    }
    if (unlocked >= 10) {
      return (
        primary: const Color(0xFF0F766E),
        secondary: const Color(0xFF115E59),
        soft: const Color(0xFFDCFDF7),
        label: 'Фон: Мята (10 наград)',
      );
    }
    if (unlocked >= 6) {
      return (
        primary: const Color(0xFFD97706),
        secondary: const Color(0xFFB45309),
        soft: const Color(0xFFFEF3C7),
        label: 'Фон: Закат (6 наград)',
      );
    }
    if (unlocked >= 3) {
      return (
        primary: const Color(0xFF1D4ED8),
        secondary: const Color(0xFF1E40AF),
        soft: const Color(0xFFDBEAFE),
        label: 'Фон: Сапфир (3 награды)',
      );
    }
    return (
      primary: _bluePrimary,
      secondary: _blueDeep,
      soft: _blueSoft,
      label: null,
    );
  }

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
        final isLandscape =
            MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
        return AlertDialog(
          backgroundColor: AppThemeColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 24 : 40,
            vertical: isLandscape ? 16 : 24,
          ),
          title: const Text('Изменить имя'),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Например: Маша',
                counterText: '',
              ),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: isLandscape
                    ? MediaQuery.of(context).size.height * 0.86
                    : MediaQuery.of(context).size.height * 0.72,
              ),
              padding: EdgeInsets.fromLTRB(20, isLandscape ? 12 : 16, 20, 20),
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Выбери класс',
                      style: TextStyle(
                        fontSize: isLandscape ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 10 : 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(7, (i) {
                        final grade = i + 5;
                        final isSelected = selected == grade;
                        final cs = Theme.of(context).colorScheme;
                        return ChoiceChip(
                          label: Text('$grade класс'),
                          selected: isSelected,
                          onSelected: (_) => setModalState(() => selected = grade),
                          selectedColor: cs.primary.withValues(alpha: 0.18),
                          labelStyle: TextStyle(
                            color: isSelected ? cs.primary : AppThemeColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: isSelected ? cs.primary : AppThemeColors.border(context),
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Сохранить класс'),
                      ),
                    ),
                  ],
                ),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
        final maxHeight = isLandscape
            ? MediaQuery.of(context).size.height * 0.9
            : 420.0;
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: EdgeInsets.fromLTRB(20, isLandscape ? 12 : 16, 20, 20),
          decoration: BoxDecoration(
            color: AppThemeColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Text(
                'Выбери аватарку',
                style: TextStyle(
                  fontSize: isLandscape ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              SizedBox(height: isLandscape ? 10 : 14),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 5 : 4,
                    mainAxisSpacing: isLandscape ? 10 : 12,
                    crossAxisSpacing: isLandscape ? 10 : 12,
                    childAspectRatio: isLandscape ? 0.85 : 0.9,
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

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth <= 390;
    final userName = ProgressService.getUserName();
    final currentGrade = ProgressService.getCurrentGrade();
    final solved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final streak = ProgressService.getStreakDays();
    final achievementsUnlocked = AchievementsService.getUnlockedCount();
    final achievementsTotal = AchievementsService.getTotalCount();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _equippedPalette();
    final skinPrimary = palette.primary;
    final skinSoft = palette.soft;
    final equippedLabel = palette.label;
    final bgColor = AppThemeColors.background(context);
    final cardBg = AppThemeColors.surface(context);
    final ratio = achievementsTotal == 0 ? 0.0 : achievementsUnlocked / achievementsTotal;
    final colorScheme = Theme.of(context).colorScheme;
    final quickAccentA = isDark ? AppColors.purple : AppColorsLight.purple;
    final quickAccentB = isDark ? AppColors.orange : AppColorsLight.orange;
    final quickAccentC = isDark ? AppColors.success : AppColorsLight.success;
    final quickAccentD = isDark ? AppColors.pink : AppColorsLight.pink;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          primary: false,
          key: const ValueKey('profile_list'),
          padding: EdgeInsets.all(isPhone ? 14 : 20),
          children: [
            _EntranceSection(
              delayMs: 0,
              child: Text(
                'Профиль',
                style: TextStyle(
                  fontSize: isPhone ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _EntranceSection(
              delayMs: 40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isPhone ? 14 : 20),
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : Colors.white.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : skinPrimary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarActions,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        children: [
                          UserAvatarDisplay(size: isPhone ? 82 : 92, showBorder: true),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: Colors.white,
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
                              fontSize: isPhone ? 21 : 24,
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
                        fontSize: isPhone ? 13 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CompactProfileStat(
                              value: '$solved',
                              label: 'решено',
                            ),
                          ),
                          Expanded(
                            child: _CompactProfileStat(
                              value: '${accuracy.toStringAsFixed(0)}%',
                              label: 'точность',
                            ),
                          ),
                          Expanded(
                            child: _CompactProfileStat(
                              value: '$streak',
                              label: 'серия',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (equippedLabel != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          equippedLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroMiniBadge(
                          icon: Icons.military_tech_rounded,
                          label: 'Ур. ${ProgressService.getLevel()}',
                          accent: const Color(0xFFFBBF24),
                        ),
                        _HeroMiniBadge(
                          icon: Icons.monetization_on_rounded,
                          label: '${ProgressService.getCoins()} монет',
                          accent: const Color(0xFF34D399),
                        ),
                        _HeroMiniBadge(
                          icon: Icons.today_rounded,
                          label: 'Сегодня +${ProgressService.getTodayCompletedCount()}',
                          accent: const Color(0xFFA78BFA),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _EntranceSection(
              delayMs: 140,
              child: _SectionTitle(
                title: 'Прогресс по наградам',
                barColors: [Color(0xFF8B5CF6), Color(0xFF14B8A6)],
              ),
            ),
            const SizedBox(height: 12),
            _EntranceSection(
              delayMs: 170,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppThemeColors.border(context)),
                  boxShadow: AppShadows.soft(context),
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
                            color: skinPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      key: ValueKey('profile_ratio_${ratio.toStringAsFixed(3)}'),
                      tween: Tween(begin: 0, end: ratio.clamp(0, 1)),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedRatio, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(
                                  color: isDark
                                      ? AppThemeColors.border(context)
                                      : skinSoft,
                                ),
                                FractionallySizedBox(
                                  widthFactor: animatedRatio,
                                  alignment: Alignment.centerLeft,
                                  child: ColoredBox(color: skinPrimary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _EntranceSection(
              delayMs: 200,
              child: _SectionTitle(
                title: 'Профиль и данные',
                barColors: [Color(0xFFF97316), Color(0xFFEC4899)],
              ),
            ),
            const SizedBox(height: 12),
            _EntranceSection(
              delayMs: 230,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionButton(
                    title: 'Изменить имя',
                    icon: Icons.badge_outlined,
                    color: quickAccentA,
                    onTap: _editName,
                  ),
                  _QuickActionButton(
                    title: 'Сменить аватар',
                    icon: Icons.face_rounded,
                    color: quickAccentB,
                    onTap: _showAvatarActions,
                  ),
                  _QuickActionButton(
                    title: 'Фото из галереи',
                    icon: Icons.photo_library_rounded,
                    color: quickAccentC,
                    onTap: _pickPhotoFromGallery,
                  ),
                  _QuickActionButton(
                    title: 'Сменить класс',
                    icon: Icons.school_rounded,
                    color: quickAccentD,
                    onTap: _changeGrade,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _EntranceSection(
              delayMs: 260,
              child: _SectionTitle(
                title: 'Настройки',
                barColors: [Color(0xFF64748B), Color(0xFF3B82F6)],
              ),
            ),
            const SizedBox(height: 12),
            _EntranceSection(
              delayMs: 290,
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppThemeColors.border(context)),
                  boxShadow: AppShadows.soft(context),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: 'Имя',
                      subtitle: userName,
                      icon: Icons.person_outline_rounded,
                      iconColor: quickAccentA,
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
                      iconColor: quickAccentB,
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
                      iconColor: quickAccentD,
                      trailing: TextButton(
                        onPressed: _changeGrade,
                        child: const Text('Изменить'),
                      ),
                    ),
                    const _DividerLine(),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      iconColor: quickAccentB,
                      title: 'Выйти из аккаунта',
                      onTap: () async {
                        await AuthService.signOut();
                        if (!context.mounted) return;
                        context.go(AppRoutes.auth);
                      },
                    ),
                    const _DividerLine(),
                    SwitchListTile(
                      value: themeProvider.autoByTime,
                      onChanged: (value) => themeProvider.setAutoByTime(value),
                      title: Text(
                        'Авто-тема (день/ночь)',
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        themeProvider.autoByTime
                            ? 'Включена: тема меняется по времени'
                            : 'Выключена: ручной выбор',
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                      secondary: Icon(
                        themeProvider.autoByTime
                            ? Icons.brightness_auto_rounded
                            : (isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                        color: quickAccentC,
                      ),
                      activeThumbColor: colorScheme.primary,
                    ),
                    if (!themeProvider.autoByTime) ...[
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
                          color: quickAccentA,
                        ),
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
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
  const _SectionTitle({
    required this.title,
    this.barColors,
  });
  final String title;
  final List<Color>? barColors;

  @override
  Widget build(BuildContext context) {
    final colors = barColors ??
        <Color>[
          AppColors.accent,
          AppColors.purple,
        ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: colors.first,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroMiniBadge extends StatelessWidget {
  const _HeroMiniBadge({
    required this.icon,
    required this.label,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntranceSection extends StatefulWidget {

  const _EntranceSection({
    required this.child,
    this.delayMs = 0,
  });
  final Widget child;
  final int delayMs;

  @override
  State<_EntranceSection> createState() => _EntranceSectionState();
}

class _EntranceSectionState extends State<_EntranceSection> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.03),
        child: widget.child,
      ),
    );
  }
}

class _CompactProfileStat extends StatelessWidget {
  const _CompactProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.84),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width - 40;
    final cardWidth = (availableWidth - 12) / 2;
    return SizedBox(
      width: cardWidth.clamp(140.0, 220.0),
      child: _PressableTile(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
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

class _PressableTile extends StatefulWidget {

  const _PressableTile({
    required this.child,
    required this.onTap,
  });
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.985 : (_hovered ? 1.01 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _InteractiveListTileShell(
      onTap: trailing == null ? null : () {},
      child: ListTile(
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
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InteractiveListTileShell(
      onTap: onTap,
      child: ListTile(
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
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
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

class _BackgroundInventoryTile extends StatelessWidget {
  const _BackgroundInventoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: selected ? color : AppThemeColors.textHint(context),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryStatChip extends StatelessWidget {
  const _InventoryStatChip({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppThemeColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveListTileShell extends StatefulWidget {

  const _InteractiveListTileShell({
    required this.child,
    this.onTap,
  });
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_InteractiveListTileShell> createState() => _InteractiveListTileShellState();
}

class _InteractiveListTileShellState extends State<_InteractiveListTileShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        color: _hovered
            ? AppThemeColors.accentLight(context).withValues(alpha: 0.35)
            : Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
