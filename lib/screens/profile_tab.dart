import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../services/progress_service.dart';
import '../services/achievements_service.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar_display.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    try {
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

      return Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: SafeArea(
          // Explicit key prevents PageStorage from restoring a scroll offset
          // from a previously visited tab (common on Flutter Web).
          child: ListView(
            key: const ValueKey('profile_list'),
            padding: const EdgeInsets.all(20),
            children: [
              // Helps verify ProfileTab is actually rendering (especially on Web).
              Text(
                'Профиль',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Column(
                  children: [
                    const UserAvatarDisplay(size: 88),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currentGrade класс',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                    if (isGuest) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeColors.accentLight(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Гостевой режим',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Статистика'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(label: 'Решено', value: '$solved'),
                  _StatCard(
                      label: 'Точность',
                      value: '${accuracy.toStringAsFixed(0)}%'),
                  _StatCard(label: 'Серия', value: '$streak дн.'),
                  _StatCard(
                      label: 'Награды',
                      value: '$achievementsUnlocked/$achievementsTotal'),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Настройки'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: 'Имя',
                      subtitle: userName,
                      icon: Icons.person_outline_rounded,
                    ),
                    _DividerLine(),
                    _SettingsTile(
                      title: 'Класс',
                      subtitle: '$currentGrade класс',
                      icon: Icons.school_outlined,
                    ),
                    _DividerLine(),
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
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.accent,
                      ),
                      activeThumbColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppThemeColors.border(context)),
                ),
                child: Text(
                  'Упрощённая версия профиля. Мы временно отключили сложные блоки, чтобы сайт стабильно открывался на web.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppThemeColors.textSecondary(context),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Ошибка в ProfileTab: $e',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }
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

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppThemeColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
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
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppThemeColors.border(context),
    );
  }
}
