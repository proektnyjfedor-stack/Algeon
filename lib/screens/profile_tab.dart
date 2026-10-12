import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/achievements_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/accent_color_settings.dart';
import '../widgets/avatar_builder.dart';
import '../widgets/avatars.dart';
import '../widgets/user_avatar_display.dart';
import '../widgets/progress_backup_dialog.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final ScrollController _scrollController;
  final ImagePicker _imagePicker = ImagePicker();
  static const List<_ProfileBackgroundOption> _backgroundOptions = [
    _ProfileBackgroundOption(
      id: 'indigo',
      title: 'Indigo',
      subtitle: 'Calm blue',
      icon: Icons.water_drop_rounded,
      primary: Color(0xFF4F46E5),
      soft: Color(0xFFE0E7FF),
    ),
    _ProfileBackgroundOption(
      id: 'emerald',
      title: 'Emerald',
      subtitle: 'Fresh green',
      icon: Icons.eco_rounded,
      primary: Color(0xFF059669),
      soft: Color(0xFFD1FAE5),
    ),
    _ProfileBackgroundOption(
      id: 'sunset',
      title: 'Sunset',
      subtitle: 'Warm orange',
      icon: Icons.wb_sunny_rounded,
      primary: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
    ),
    _ProfileBackgroundOption(
      id: 'violet',
      title: 'Violet',
      subtitle: 'Soft violet',
      icon: Icons.auto_awesome_rounded,
      primary: Color(0xFF7C3AED),
      soft: Color(0xFFEDE9FE),
    ),
    _ProfileBackgroundOption(
      id: 'rose',
      title: 'Rose',
      subtitle: 'Pink accent',
      icon: Icons.favorite_rounded,
      primary: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E6),
    ),
    _ProfileBackgroundOption(
      id: 'graphite',
      title: 'Graphite',
      subtitle: 'Neutral dark',
      icon: Icons.dark_mode_rounded,
      primary: Color(0xFF334155),
      soft: Color(0xFFE2E8F0),
    ),
  ];

  _ProfileBackgroundOption _selectedBackground() {
    final selectedId = ProgressService.getProfileBackground();
    return _backgroundOptions.firstWhere(
      (x) => x.id == selectedId,
      orElse: () => _backgroundOptions.first,
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

  Future<void> _openBackup() async {
    final theme = context.read<ThemeProvider>();
    final restored = await showDialog<bool>(
      context: context,
      builder: (_) => const ProgressBackupDialog(),
    );
    if (restored != true || !mounted) return;
    await LanguageService.instance.init();
    await theme.reload();
    if (mounted) {
      setState(() {});
      _showSnack(
        context.read<LanguageService>().isEnglish
            ? 'Progress restored'
            : 'Прогресс восстановлен',
      );
    }
  }

  Future<void> _editName() async {
    final t = context.read<LanguageService>().t;
    final controller = TextEditingController(
      text: ProgressService.getUserName(),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height;
        return AlertDialog(
          backgroundColor: AppThemeColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 24 : 40,
            vertical: isLandscape ? 16 : 24,
          ),
          title: Text(t('profile.editName')),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: t('profile.nameExample'),
                counterText: '',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('common.save')),
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
      _showSnack(t('profile.nameUpdated'));
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final t = context.read<LanguageService>().t;
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
      _showSnack(t('profile.photoUpdated'));
    } catch (e) {
      _showSnack(t('profile.photoPickFailed').replaceAll('{error}', '$e'));
    }
  }

  Future<void> _changeGrade() async {
    final t = context.read<LanguageService>().t;
    final current = ProgressService.getCurrentGrade();
    int selected = current;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height;
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t('profile.pickGrade'),
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
                        children: List.generate(11, (i) {
                          final grade = i + 1;
                          final isSelected = selected == grade;
                          final cs = Theme.of(context).colorScheme;
                          return ChoiceChip(
                            label: Text(
                              context.read<LanguageService>().isEnglish
                                  ? 'Grade $grade'
                                  : '$grade класс',
                            ),
                            selected: isSelected,
                            onSelected: (_) =>
                                setModalState(() => selected = grade),
                            selectedColor: cs.primary.withValues(alpha: 0.18),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? cs.primary
                                  : AppThemeColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? cs.primary
                                  : AppThemeColors.border(context),
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          child: Text(t('profile.saveGrade')),
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
      _showSnack(t('profile.gradeUpdated'));
    }
  }

  Future<void> _changeLanguage() async {
    final lang = context.read<LanguageService>();
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              _ActionTile(
                icon: Icons.language_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                title: lang.t('lang.ru'),
                onTap: () => Navigator.pop(context, AppLanguage.ru),
              ),
              _ActionTile(
                icon: Icons.language_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                title: lang.t('lang.en'),
                onTap: () => Navigator.pop(context, AppLanguage.en),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    await lang.setLanguage(selected);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openAvatarBuilder() async {
    final t = context.read<LanguageService>().t;
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
            _showSnack(t('profile.customAvatarSaved'));
          },
        );
      },
    );
  }

  Future<void> _openPresetAvatars() async {
    final t = context.read<LanguageService>().t;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLandscape =
            MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height;
        final unlockedSkins = AchievementsService.getUnlockedAvatarSkinIds()
            .toSet();
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
                t('profile.pickAvatar'),
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
                    final isUnlocked = unlockedSkins.contains(avatar.id);
                    return GestureDetector(
                      onTap: !isUnlocked
                          ? () => _showSnack(t('profile.skinLockedHint'))
                          : () async {
                              await ProgressService.setAvatar(avatar.id);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              setState(() {});
                              _showSnack(t('profile.avatarUpdated'));
                            },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Opacity(
                                opacity: isUnlocked ? 1 : 0.45,
                                child: AvatarWidget(
                                  avatarId: avatar.id,
                                  size: 56,
                                ),
                              ),
                              if (!isUnlocked)
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            avatar.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isUnlocked
                                  ? AppThemeColors.textSecondary(context)
                                  : AppThemeColors.textHint(context),
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
                  title: context.read<LanguageService>().t(
                    'profile.choosePresetAvatar',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openPresetAvatars();
                  },
                ),
                _ActionTile(
                  icon: Icons.auto_fix_high_rounded,
                  iconColor: AppColors.orange,
                  title: context.read<LanguageService>().t(
                    'profile.openAvatarBuilder',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openAvatarBuilder();
                  },
                ),
                _ActionTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: Theme.of(context).colorScheme.primary,
                  title: context.read<LanguageService>().t(
                    'profile.uploadPhoto',
                  ),
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
    final lang = context.watch<LanguageService>();
    final t = lang.t;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth <= 390;
    final userName = ProgressService.getUserName();
    final currentGrade = ProgressService.getCurrentGrade();
    final solved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final streak = ProgressService.getStreakDays();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _selectedBackground();
    final skinPrimary = palette.primary;
    final skinSoft = palette.soft;
    final bgColor = AppThemeColors.background(context);
    final cardBg = AppThemeColors.surface(context);
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
                t('nav.profile'),
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: skinPrimary.withValues(alpha: isDark ? 0.55 : 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                          UserAvatarDisplay(
                            size: isPhone ? 82 : 92,
                            showBorder: true,
                          ),
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
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _editName,
                          icon: const Icon(Icons.edit_outlined),
                          color: AppThemeColors.textSecondary(context),
                          tooltip: t('profile.editName'),
                        ),
                      ],
                    ),
                    Text(
                      lang.isEnglish
                          ? 'Grade $currentGrade'
                          : '$currentGrade класс',
                      style: TextStyle(
                        fontSize: isPhone ? 13 : 14,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: skinSoft.withValues(alpha: isDark ? 0.18 : 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: skinPrimary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CompactProfileStat(
                              value: '$solved',
                              label: t('profile.solved'),
                            ),
                          ),
                          Expanded(
                            child: _CompactProfileStat(
                              value: '${accuracy.toStringAsFixed(0)}%',
                              label: t('profile.accuracy'),
                            ),
                          ),
                          Expanded(
                            child: _CompactProfileStat(
                              value: '$streak',
                              label: t('profile.streak'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroMiniBadge(
                          icon: Icons.military_tech_rounded,
                          label: t('profile.level').replaceAll(
                            '{level}',
                            '${ProgressService.getLevel()}',
                          ),
                          accent: const Color(0xFFFBBF24),
                        ),
                        _HeroMiniBadge(
                          icon: Icons.emoji_events_rounded,
                          label: t('profile.rewardsCount').replaceAll(
                            '{count}',
                            '${AchievementsService.getUnlockedCount()}',
                          ),
                          accent: const Color(0xFF34D399),
                        ),
                        _HeroMiniBadge(
                          icon: Icons.today_rounded,
                          label: t('profile.todayPlus').replaceAll(
                            '{count}',
                            '${ProgressService.getTodayCompletedCount()}',
                          ),
                          accent: const Color(0xFFA78BFA),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _EntranceSection(
              delayMs: 260,
              child: _SectionTitle(
                title: t('settings.title'),
                barColors: [const Color(0xFF64748B), colorScheme.primary],
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
                      title: t('settings.name'),
                      subtitle: userName,
                      icon: Icons.person_outline_rounded,
                      iconColor: quickAccentA,
                      onTap: _editName,
                      actionLabel: t('common.edit'),
                    ),
                    const _DividerLine(),
                    _SettingsTile(
                      title: t('settings.avatar'),
                      subtitle: t('settings.avatarSub'),
                      icon: Icons.face_rounded,
                      iconColor: quickAccentB,
                      onTap: _showAvatarActions,
                      actionLabel: t('common.open'),
                    ),
                    const _DividerLine(),
                    _SettingsTile(
                      title: t('settings.grade'),
                      subtitle: lang.isEnglish
                          ? 'Grade $currentGrade'
                          : '$currentGrade класс',
                      icon: Icons.school_outlined,
                      iconColor: quickAccentD,
                      onTap: _changeGrade,
                      actionLabel: t('common.edit'),
                    ),
                    const _DividerLine(),
                    _SettingsTile(
                      title: t('settings.language'),
                      subtitle: lang.isEnglish ? t('lang.en') : t('lang.ru'),
                      icon: Icons.language_rounded,
                      iconColor: quickAccentA,
                      onTap: _changeLanguage,
                      actionLabel: t('common.edit'),
                    ),
                    const _DividerLine(),
                    const AccentColorSettings(),
                    const _DividerLine(),
                    SwitchListTile(
                      value: themeProvider.followSystem,
                      onChanged: (value) =>
                          themeProvider.setFollowSystem(value),
                      title: Text(
                        t('settings.autoTheme'),
                        style: TextStyle(
                          color: AppThemeColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        themeProvider.followSystem
                            ? t('settings.autoThemeOn')
                            : t('settings.autoThemeOff'),
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                        ),
                      ),
                      secondary: Icon(
                        themeProvider.followSystem
                            ? Icons.brightness_auto_rounded
                            : (isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded),
                        color: quickAccentC,
                      ),
                      activeThumbColor: colorScheme.primary,
                    ),
                    if (!themeProvider.followSystem) ...[
                      const _DividerLine(),
                      SwitchListTile(
                        value: isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        title: Text(
                          t('settings.darkTheme'),
                          style: TextStyle(
                            color: AppThemeColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isDark
                              ? t('settings.enabled')
                              : t('settings.disabled'),
                          style: TextStyle(
                            color: AppThemeColors.textSecondary(context),
                          ),
                        ),
                        secondary: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: quickAccentA,
                        ),
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.isEnglish ? 'Your progress' : 'Твой прогресс',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.isEnglish
                          ? 'Saved in this browser. Back it up to continue on another device.'
                          : 'Сохрани копию для переноса на другое устройство.',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openBackup,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: Text(
                        lang.isEnglish
                            ? 'Back up and restore'
                            : 'Сохранить и восстановить',
                      ),
                    ),
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

class _ProfileBackgroundOption {
  const _ProfileBackgroundOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.soft,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final Color soft;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.barColors});
  final String title;
  final List<Color>? barColors;

  @override
  Widget build(BuildContext context) {
    final colors =
        barColors ??
        <Color>[Theme.of(context).colorScheme.primary, AppColors.purple];
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
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntranceSection extends StatefulWidget {
  const _EntranceSection({required this.child, this.delayMs = 0});
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
  const _CompactProfileStat({required this.value, required this.label});

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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.actionLabel,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return _InteractiveListTileShell(
      onTap: null,
      child: ListTile(
        onTap: onTap,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppThemeColors.textSecondary(context)),
        ),
        trailing: Tooltip(
          message: actionLabel,
          child: const Icon(Icons.chevron_right_rounded),
        ),
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

class _InteractiveListTileShell extends StatefulWidget {
  const _InteractiveListTileShell({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_InteractiveListTileShell> createState() =>
      _InteractiveListTileShellState();
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
          child: widget.onTap == null
              ? widget.child
              : InkWell(onTap: widget.onTap, child: widget.child),
        ),
      ),
    );
  }
}
