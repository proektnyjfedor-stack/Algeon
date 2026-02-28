/// Achievements Screen — экран достижений
/// 
/// Показывает все достижения и прогресс

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/achievements_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementsService.getAll();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final locked = achievements.where((a) => !a.isUnlocked).toList();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Достижения'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Прогресс
            _buildProgressCard(unlocked.length, achievements.length),
            
            const SizedBox(height: 24),
            
            // Разблокированные
            if (unlocked.isNotEmpty) ...[
              _buildSectionTitle('Получено', unlocked.length),
              const SizedBox(height: 12),
              _buildAchievementsGrid(unlocked, isUnlocked: true),
              const SizedBox(height: 24),
            ],
            
            // Заблокированные
            if (locked.isNotEmpty) ...[
              _buildSectionTitle('Ещё не получено', locked.length),
              const SizedBox(height: 12),
              _buildAchievementsGrid(locked, isUnlocked: false),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(int unlocked, int total) {
    final progress = total > 0 ? unlocked / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Круговой прогресс
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Прогресс',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unlocked из $total',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMotivationText(progress),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationText(double progress) {
    if (progress >= 1.0) return 'Все достижения получены!';
    if (progress >= 0.75) return 'Почти все собрано!';
    if (progress >= 0.5) return 'Отличный прогресс!';
    if (progress >= 0.25) return 'Хорошее начало!';
    return 'Начни собирать достижения!';
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(title, style: AppTypography.h3),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(List<Achievement> achievements, {required bool isUnlocked}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement, isUnlocked: isUnlocked);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, {required bool isUnlocked}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surface : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: isUnlocked 
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? AppColors.accentLight 
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isUnlocked
                  ? Icon(
                      achievement.icon,
                      color: AppColors.accent,
                      size: 24,
                    )
                  : const Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                      size: 20,
                    ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Название
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 2),
          
          // Описание
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
