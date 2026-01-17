/// Главный экран с нижней навигацией
/// 
/// Три вкладки с разделителями (как на макете Figma)

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'exams_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    ExamsTab(),
    HomeTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Задания
                _buildNavItem(
                  index: 0,
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note,
                ),
                
                // Разделитель
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.border,
                ),
                
                // Главная (центральная)
                _buildCenterNavItem(),
                
                // Разделитель
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.border,
                ),
                
                // Профиль
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.accent : AppColors.textHint,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    final isSelected = _currentIndex == 1;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.home,
          color: isSelected ? Colors.white : AppColors.textHint,
          size: 24,
        ),
      ),
    );
  }
}
