/// Profile Tab — Профиль
/// Величественный дизайн Algeon

import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../data/tasks_data.dart';
import '../services/progress_service.dart';
import '../services/achievements_service.dart';
import '../widgets/avatars.dart';
import '../widgets/avatar_builder.dart';
import '../widgets/user_avatar_display.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildStatsSection()),
          SliverToBoxAdapter(child: _buildProgressSection()),
          SliverToBoxAdapter(child: _buildAchievementsPreview()),
          SliverToBoxAdapter(child: _buildSettingsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  AvatarData _getCurrentAvatar() {
    final avatarId = ProgressService.getAvatar();
    if (avatarId == 'custom') {
      final customData = ProgressService.getCustomAvatar();
      if (customData != null) return AvatarData.fromMap(customData);
    }
    return allAvatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => allAvatars[0],
    );
  }

  Widget _buildProfileHeader() {
    final name = ProgressService.getUserName();
    final level = ProgressService.getLevel();
    final streak = ProgressService.getStreakDays();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              // Avatar + edit
              GestureDetector(
                onTap: _showAvatarPicker,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: UserAvatarDisplay(size: 88, showBorder: false),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit_rounded,
                            color: AppColors.accent, size: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Name
              GestureDetector(
                onTap: _showNameEditor,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_outlined,
                        color: Colors.white.withValues(alpha: 0.6), size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Badges row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    label: 'Уровень $level',
                  ),
                  const SizedBox(width: 10),
                  _buildBadge(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF9600),
                    label: '$streak дней',
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required Color iconColor, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final solved = ProgressService.getTotalSolved();
    final accuracy = ProgressService.getAccuracy();
    final todaySolved = ProgressService.getTodayCompletedCount();
    final xp = solved * 10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.bar_chart_rounded, 'Статистика'),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.success,
                value: '$solved',
                label: 'Решено',
                bgColor: AppThemeColors.successLight(context),
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: Icons.track_changes_rounded,
                iconColor: AppColors.accent,
                value: '${accuracy.toStringAsFixed(0)}%',
                label: 'Точность',
                bgColor: AppThemeColors.accentLight(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.today_rounded,
                iconColor: AppColors.orange,
                value: '$todaySolved',
                label: 'Сегодня',
                bgColor: AppColors.orange.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: Icons.bolt_rounded,
                iconColor: AppColors.purple,
                value: '$xp',
                label: 'XP',
                bgColor: AppColors.purple.withValues(alpha: 0.12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppThemeColors.textPrimary(context),
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeColors.border(context), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: iconColor,
                    ),
                  ),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppThemeColors.textSecondary(context))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.school_rounded, 'Прогресс по классам'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeColors.border(context), width: 1),
            ),
            child: Column(
              children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((grade) {
                final tasks = getTasksByGrade(grade);
                final solved = ProgressService.getSolvedCountForGrade(
                  grade,
                  tasks.map((t) => t.id).toList(),
                );
                final total = tasks.length;
                final progress = total > 0 ? solved / total : 0.0;
                final isComplete = solved >= total && total > 0;
                final isCurrent = ProgressService.getCurrentGrade() == grade;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.accent
                              : isComplete
                                  ? AppColors.success
                                  : AppThemeColors.borderLight(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$grade',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isCurrent || isComplete
                                  ? Colors.white
                                  : AppThemeColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$grade класс',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.accent
                                        : AppThemeColors.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  '$solved/$total',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isComplete
                                        ? AppColors.success
                                        : AppThemeColors.textHint(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: AppThemeColors.borderLight(context),
                                valueColor: AlwaysStoppedAnimation(
                                  isComplete ? AppColors.success : AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsPreview() {
    final achievements = AchievementsService.getAll();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final recent = unlocked.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text('Достижения', style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${unlocked.length}/${achievements.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeColors.border(context), width: 1),
            ),
            child: recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            color: AppThemeColors.textHint(context), size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'Ещё нет достижений',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Решай задачи, чтобы получить первые награды!',
                          style: TextStyle(fontSize: 13, color: AppThemeColors.textHint(context)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      ...recent.map((a) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(a.icon, color: Colors.white, size: 28),
                                ),
                              ),
                            ),
                          )),
                      ...List.generate(
                          4 - recent.length,
                          (_) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.borderLight(context),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.lock_rounded,
                                          color: AppThemeColors.textHint(context),
                                          size: 24),
                                    ),
                                  ),
                                ),
                              )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.settings_rounded, 'Настройки'),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeColors.border(context), width: 1),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.school_outlined,
                  iconColor: AppColors.accent,
                  title: 'Сменить класс',
                  subtitle: '${ProgressService.getCurrentGrade()} класс',
                  onTap: _showGradeChanger,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.accent,
                  title: 'Изменить имя',
                  subtitle: ProgressService.getUserName(),
                  onTap: _showNameEditor,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.face_rounded,
                  iconColor: AppColors.purple,
                  title: 'Сменить аватар',
                  onTap: _showAvatarPicker,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  iconColor: isDark ? AppColors.accent : AppColors.orange,
                  title: 'Тема',
                  subtitle: isDark ? 'Тёмная' : 'Светлая',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeThumbColor: AppColors.accent,
                    activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppThemeColors.textSecondary(context),
                  title: 'О приложении',
                  onTap: _showAboutDialog,
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.delete_sweep_rounded,
                  iconColor: AppColors.error,
                  title: 'Сбросить прогресс',
                  subtitle: 'Удалить весь прогресс и достижения',
                  onTap: _showResetConfirmation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppThemeColors.textPrimary(context),
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppThemeColors.textSecondary(context))),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    color: AppThemeColors.textHint(context), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppThemeColors.borderLight(context),
    );
  }

  // === DIALOGS ===

  // ── Выбор аватара: галерея или конструктор ──────────────────
  void _showAvatarPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppThemeColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Сменить аватар',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            // ── Галерея ────────────────────────────────────────
            _buildAvatarOption(
              icon: Icons.photo_library_rounded,
              iconColor: Colors.white,
              bgColor: AppColors.accent,
              title: 'Фото из галереи',
              subtitle: 'Выбрать своё фото',
              onTap: () {
                // dart:html напрямую — единственный надёжный способ для Flutter Web
                // Создаём <input type="file"> и кликаем синхронно из обработчика жеста
                _pickPhotoFromGallery(sheetCtx);
              },
            ),
            const SizedBox(height: 10),
            // ── Конструктор ────────────────────────────────────
            _buildAvatarOption(
              icon: Icons.face_rounded,
              iconColor: Colors.white,
              bgColor: AppColors.purple,
              title: 'Конструктор аватара',
              subtitle: 'Создать мультяшного персонажа',
              onTap: () {
                Navigator.pop(sheetCtx);
                _openAvatarBuilder();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeColors.border(context), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppThemeColors.textPrimary(context),
                  )),
                  Text(subtitle, style: TextStyle(
                    fontSize: 12, color: AppThemeColors.textSecondary(context),
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppThemeColors.textHint(context)),
          ],
        ),
      ),
    );
  }

  /// Выбор фото через package:web — современная замена dart:html для Flutter Web.
  /// image_picker блокируется браузером из-за async-разрыва перед открытием диалога.
  void _pickPhotoFromGallery(BuildContext sheetCtx) {
    // 1. Создаём <input type="file"> и кликаем СИНХРОННО (браузер требует жест пользователя)
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = 'image/*';
    web.document.body?.append(input);

    // 2. Слушаем выбор файла
    input.addEventListener('change', (web.Event _) {
      final files = input.files;
      input.remove();
      if (files == null || files.length == 0) return;

      final file = files.item(0)!;

      // 3. Читаем через readAsDataURL — возвращает строку "data:image/...;base64,XXX"
      final reader = web.FileReader();

      reader.addEventListener('load', (web.Event _) async {
        try {
          final result = reader.result;
          if (result == null) return;
          final dataUrl = (result as JSString).toDart;
          // Обрезаем префикс "data:image/jpeg;base64," — берём только base64
          final base64Str = dataUrl.split(',').last;
          await ProgressService.setCustomPhoto(base64Str);
          if (mounted) setState(() {});
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось обработать фото')),
            );
          }
        }
      }.toJS);

      reader.addEventListener('error', (web.Event _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка чтения файла')),
          );
        }
      }.toJS);

      reader.readAsDataURL(file);
    }.toJS);

    // 4. Кликаем — открывает проводник браузера
    input.click();

    // 5. Закрываем модал ПОСЛЕ клика (не до)
    Navigator.pop(sheetCtx);
  }

  void _openAvatarBuilder() {
    final currentAvatar = _getCurrentAvatar();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AvatarBuilderSheet(
        initialAvatar: currentAvatar,
        onSave: (avatar) async {
          await ProgressService.setCustomAvatar(avatar.toMap());
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _showNameEditor() {
    HapticFeedback.lightImpact();
    final controller = TextEditingController(
        text: ProgressService.getUserName());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Изменить имя', style: TextStyle(
          color: AppThemeColors.textPrimary(context),
        )),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppThemeColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Введи имя',
            hintStyle: TextStyle(color: AppThemeColors.textHint(context)),
            filled: true,
            fillColor: AppThemeColors.borderLight(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ProgressService.setUserName(controller.text.trim());
                Navigator.of(dialogContext).pop();
                if (mounted) setState(() {});
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showGradeChanger() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
            const SizedBox(height: 20),
            Text('Выбери класс', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            )),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((grade) {
                      final isSelected = ProgressService.getCurrentGrade() == grade;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await ProgressService.setCurrentGrade(grade);
                            Navigator.pop(context);
                            if (mounted) setState(() {});
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppThemeColors.accentLight(context)
                                  : AppThemeColors.borderLight(context),
                              borderRadius: BorderRadius.circular(14),
                              border: isSelected
                                  ? Border.all(color: AppColors.accent, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$grade класс',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppThemeColors.textPrimary(context),
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.accent, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.functions_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Algeon', style: TextStyle(
              color: AppThemeColors.textPrimary(context),
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Версия 1.0.0', style: TextStyle(
              color: AppThemeColors.textPrimary(context),
            )),
            const SizedBox(height: 12),
            Text(
              'Математический тренажёр для учеников 1-4 классов. '
              'Учись с удовольствием!',
              style: TextStyle(color: AppThemeColors.textSecondary(context)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppThemeColors.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Сбросить прогресс?', style: TextStyle(
          color: AppThemeColors.textPrimary(context),
        )),
        content: Text(
            'Весь прогресс и достижения будут удалены. Это действие нельзя отменить.',
            style: TextStyle(color: AppThemeColors.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ProgressService.resetAll();
              await AchievementsService.reset();
              if (mounted) {
                context.go('/onboarding');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
