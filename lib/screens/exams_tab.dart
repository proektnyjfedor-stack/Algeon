/// Вкладка "Задания" — быстрые тесты

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../services/progress_service.dart';
import 'task_screen.dart';

class ExamsTab extends StatelessWidget {
  const ExamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Заголовок
            Row(
              children: [
                const Text(
                  '📝',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Задания',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Быстрые тесты по темам',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Карточка общего прогресса
            _buildProgressCard(context),
            
            const SizedBox(height: 24),
            
            // Список тестов
            Text(
              'Доступные тесты',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildTestCard(
              context,
              emoji: '✖️',
              title: 'Таблица умножения',
              subtitle: '10 примеров',
              color: AppColors.accent,
              grade: 2,
              topic: 'Умножение',
            ),
            
            _buildTestCard(
              context,
              emoji: '📖',
              title: 'Текстовые задачи',
              subtitle: '5 задач',
              color: const Color(0xFFF59E0B),
              grade: 2,
              topic: 'Текстовые задачи',
            ),
            
            _buildTestCard(
              context,
              emoji: '⚖️',
              title: 'Масса: кг и г',
              subtitle: '5 заданий',
              color: const Color(0xFF10B981),
              grade: 2,
              topic: 'Масса: кг и г',
            ),
            
            _buildTestCard(
              context,
              emoji: '📏',
              title: 'Длина: м, дм, см',
              subtitle: '4 задания',
              color: const Color(0xFF8B5CF6),
              grade: 2,
              topic: 'Длина: м, дм, см',
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка прогресса
  Widget _buildProgressCard(BuildContext context) {
    final solved = ProgressService.getSolvedTaskIds().length;
    final total = getAllTasks().length;
    final progress = total > 0 ? solved / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Общий прогресс',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Решено $solved из $total заданий',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Карточка теста
  Widget _buildTestCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required int grade,
    required String topic,
  }) {
    final tasks = getTasksByGradeAndTopic(grade, topic);
    final solved = ProgressService.getSolvedCountForTopic(
      topic,
      tasks.map((t) => t.id).toList(),
    );
    final total = tasks.length;
    
    return GestureDetector(
      onTap: () {
        if (tasks.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskScreen(tasks: tasks, topicName: title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Эмодзи
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$subtitle • $solved/$total',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Кнопка
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
