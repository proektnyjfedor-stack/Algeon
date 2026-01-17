/// Вкладка "Профиль" — аватарка, имя, статистика

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import 'login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // Список доступных аватарок
  static const List<String> _avatars = [
    '👦', '👧', '🧑', '👨', '👩', 
    '🦊', '🐱', '🐶', '🐼', '🦁',
    '🚀', '⭐', '🎯', '🎨', '📚',
  ];
  
  String _selectedAvatar = '👦';
  
  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }
  
  void _loadAvatar() {
    final saved = ProgressService.getAvatar();
    if (saved != null) {
      setState(() => _selectedAvatar = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final solvedCount = ProgressService.getSolvedTaskIds().length;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Аватарка (можно нажать для выбора)
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _selectedAvatar,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                  // Иконка редактирования
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Имя (можно нажать для редактирования)
            GestureDetector(
              onTap: _showNameEditor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.displayName ?? 'Ученик',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              user?.email ?? '',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Статистика
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        icon: '✅',
                        value: '$solvedCount',
                        label: 'Решено',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: '🔥',
                        value: '${ProgressService.getStreak()}',
                        label: 'Дней подряд',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: '⭐',
                        value: '${ProgressService.getLevel()}',
                        label: 'Уровень',
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Действия
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.refresh,
                    title: 'Сбросить прогресс',
                    onTap: _resetProgress,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    onTap: _showAbout,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Выйти',
                    color: AppColors.error,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textHint),
      onTap: onTap,
    );
  }

  /// Выбор аватарки
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выбери аватарку',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _avatars.map((avatar) {
                final isSelected = avatar == _selectedAvatar;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatar = avatar);
                    ProgressService.setAvatar(avatar);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentLight : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Редактирование имени
  void _showNameEditor() {
    final controller = TextEditingController(
      text: AuthService.currentUser?.displayName ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить имя'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Введите имя',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await AuthService.updateDisplayName(controller.text);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  /// Сброс прогресса
  void _resetProgress() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text('Все результаты будут удалены'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await ProgressService.resetAll();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Прогресс сброшен')),
                );
              }
            },
            child: const Text('Сбросить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// О приложении
  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('MathPilot'),
        content: const Text(
          'Математический тренажёр\n\n'
          'Версия 1.0.0\n\n'
          'Создано для Mars Fest 🚀',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Выход
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
