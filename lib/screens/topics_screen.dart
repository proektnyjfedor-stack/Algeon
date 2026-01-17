/// Экран списка тем

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/tasks_data.dart';
import '../services/progress_service.dart';
import 'task_screen.dart';

class TopicsScreen extends StatefulWidget {
  final int grade;

  const TopicsScreen({
    super.key,
    required this.grade,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late List<TopicInfo> _topics;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  void _loadTopics() {
    _topics = getTopicsInfoByGrade(widget.grade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.grade} класс'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _topics.isEmpty
          ? _buildEmptyState()
          : _buildTopicsList(),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Темы скоро появятся',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Список тем
  Widget _buildTopicsList() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _loadTopics());
      },
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return _TopicCard(
            topic: topic,
            grade: widget.grade,
            onTap: () => _onTopicSelected(topic.name),
          );
        },
      ),
    );
  }

  /// Выбор темы
  void _onTopicSelected(String topicName) {
    final tasks = getTasksByGradeAndTopic(widget.grade, topicName);
    
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('В этой теме пока нет задач')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(
          tasks: tasks,
          topicName: topicName,
        ),
      ),
    ).then((_) => setState(() {}));
  }
}

/// Карточка темы
class _TopicCard extends StatelessWidget {
  final TopicInfo topic;
  final int grade;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Прогресс
    final tasks = getTasksByGradeAndTopic(grade, topic.name);
    final taskIds = tasks.map((t) => t.id).toList();
    final solvedCount = ProgressService.getSolvedCountForTopic(topic.name, taskIds);
    final progress = taskIds.isEmpty ? 0.0 : solvedCount / taskIds.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.accent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Иконка
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      topic.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Название и прогресс
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Прогресс-бар
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0 
                                      ? AppColors.success 
                                      : AppColors.accent,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$solvedCount/${topic.taskCount}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Стрелка
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
