import 'package:flutter/material.dart';

/// Secondary explanations stay available without dominating the task.
class LearningNote extends StatelessWidget {
  const LearningNote({super.key, required this.title, required this.text});
  final String title, text;
  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 16),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

String studyDateLabel(DateTime date) {
  const months = [
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июня',
    'июля',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];
  return '${date.day} ${months[date.month - 1]}${date.year == DateTime.now().year ? '' : ' ${date.year}'}';
}
