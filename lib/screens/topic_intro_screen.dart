/// Topic Intro Screen — экран с подробным объяснением темы перед задачами
///
/// Структурированная теория: определения, формулы, примеры,
/// визуальные иллюстрации, пошаговые алгоритмы и советы.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/sound_service.dart';
import '../models/task.dart';
import '../data/tasks_data.dart';
import '../data/topic_theory.dart';

class TopicIntroScreen extends StatelessWidget {
  const TopicIntroScreen({
    super.key,
    required this.topicName,
    required this.tasks,
  });
  final String topicName;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final theory = getTopicTheory(topicName);
    final icon = getTopicIcon(topicName);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(context),

            // Content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(context, icon, theory),
                        const SizedBox(height: 24),

                        // Theory sections
                        if (theory != null)
                          ...theory.sections
                              .where((section) => section.type != TheorySectionType.visual)
                              .map((section) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildSection(context, section),
                              ))
                        else
                          _buildFallbackContent(context),
                        const SizedBox(height: 8),
                        _buildBottomButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppThemeColors.surface(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppThemeColors.textSecondary(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemeColors.accentLight(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: AppColors.accent),
                SizedBox(width: 6),
                Text(
                  'Теория',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, IconData icon, TopicTheory? theory) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppThemeColors.accentLight(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.accent, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          topicName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppThemeColors.textPrimary(context),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          theory?.subtitle ?? '${tasks.length} задач',
          style: TextStyle(
            fontSize: 14,
            color: AppThemeColors.textHint(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, TheorySection section) {
    switch (section.type) {
      case TheorySectionType.definition:
        return _buildDefinitionCard(context, section);
      case TheorySectionType.formula:
        return _buildFormulaCard(context, section);
      case TheorySectionType.example:
        return _buildExampleCard(context, section);
      case TheorySectionType.visual:
        return const SizedBox.shrink();
      case TheorySectionType.tip:
        return _buildTipCard(context, section);
      case TheorySectionType.table:
        return _buildTableCard(context, section);
      case TheorySectionType.steps:
        return _buildStepsCard(context, section);
    }
  }

  // --- DEFINITION ---
  Widget _buildDefinitionCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (section.emoji != null) ...[
                Text(section.emoji!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  section.title ?? 'Определение',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- FORMULA ---
  Widget _buildFormulaCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.accentLight(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.functions_rounded, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                section.title ?? 'Формула',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemeColors.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              section.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                height: 1.7,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- EXAMPLE ---
  Widget _buildExampleCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.success, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                section.title ?? 'Пример',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              section.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ],
          if (section.items != null) ...[
            const SizedBox(height: 12),
            ...section.items!.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppThemeColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }


  // --- TIP ---
  Widget _buildTipCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.orangeLight(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(section.emoji ?? '💡', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                section.title ?? 'Совет',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- TABLE ---
  Widget _buildTableCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded,
                  color: AppColors.purple, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title ?? 'Таблица',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ],
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              section.content,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (section.items != null)
            ...section.items!.asMap().entries.map((e) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: e.key.isEven
                        ? AppThemeColors.borderLight(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // --- STEPS ---
  Widget _buildStepsCard(BuildContext context, TheorySection section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_numbered_rounded,
                  color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title ?? 'Алгоритм',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          if (section.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              section.content,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ],
          if (section.items != null) ...[
            const SizedBox(height: 14),
            ...section.items!.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppThemeColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // --- FALLBACK (если теории нет) ---
  Widget _buildFallbackContent(BuildContext context) {
    final description = getTopicDescription(topicName);
    if (description == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppThemeColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () {
              SoundService.hapticMedium();
              SoundService.playStart();
              context.pushReplacement(
                '/learn/topic',
                extra: {'name': topicName, 'tasks': tasks},
              );
            }
            ,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Начать задачи',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${tasks.length})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

}
