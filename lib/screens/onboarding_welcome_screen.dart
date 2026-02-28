/// Onboarding — Кастомизация персонажа, имя, класс
///
/// 3 шага без выбора пола

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/progress_service.dart';
import '../widgets/avatars.dart';
import '../widgets/app_logo.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  final _nameController = TextEditingController();
  int _currentPage = 0;
  int? _selectedGrade;

  // Кастомизация персонажа
  AvatarData _avatarData = defaultCustomAvatar;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _skip() async {
    await ProgressService.setUserName('Ученик');
    await ProgressService.setAvatar('boy_blue');
    await ProgressService.setCurrentGrade(1);
    await ProgressService.setOnboardingComplete(true);

    if (!mounted) return;
    context.go('/learn');
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ProgressService.setUserName(name);
    }
    await ProgressService.setCustomAvatar(_avatarData.toMap());
    await ProgressService.setCurrentGrade(_selectedGrade ?? 1);
    await ProgressService.setOnboardingComplete(true);

    if (!mounted) return;
    context.go('/learn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Progress bar + Skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _prevPage,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppThemeColors.borderLight(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppThemeColors.textSecondary(context),
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProgressDots()),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Пропустить',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textHint(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages — conditional rendering (no hidden widgets competing for gestures)
                Expanded(
                  child: _currentPage == 0
                      ? _buildCustomizePage()
                      : _currentPage == 1
                          ? _buildNamePage()
                          : _buildGradePage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= _currentPage;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accent
                  : AppThemeColors.borderLight(context),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  // === PAGE 1: Customize Character ===
  Widget _buildCustomizePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Logo and welcome
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogoIcon(size: 40),
              const SizedBox(width: 12),
              Text(
                'Algeon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Создай своего персонажа',
            style: TextStyle(
              fontSize: 15,
              color: AppThemeColors.textSecondary(context),
            ),
          ),

          const SizedBox(height: 20),

          // Avatar preview
          AvatarWidget(avatarData: _avatarData, size: 90),

          const SizedBox(height: 16),

          // Customization options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Причёска
                  _buildCustomizeSection(
                    'Причёска',
                    Icons.content_cut_rounded,
                    _buildHairStyleRow(),
                  ),

                  // Цвет кожи
                  _buildCustomizeSection(
                    'Кожа',
                    Icons.palette_rounded,
                    _buildColorRow(
                      avatarSkinColors,
                      _avatarData.skinColor,
                      (color) => setState(() => _avatarData = _avatarData.copyWith(skinColor: color)),
                    ),
                  ),

                  // Цвет волос
                  _buildCustomizeSection(
                    'Цвет волос',
                    Icons.brush_rounded,
                    _buildColorRow(
                      avatarHairColors,
                      _avatarData.hairColor,
                      (color) => setState(() => _avatarData = _avatarData.copyWith(hairColor: color)),
                    ),
                  ),

                  // Цвет одежды
                  _buildCustomizeSection(
                    'Одежда',
                    Icons.checkroom_rounded,
                    _buildColorRow(
                      avatarShirtColors,
                      _avatarData.shirtColor,
                      (color) => setState(() => _avatarData = _avatarData.copyWith(shirtColor: color)),
                    ),
                  ),

                  // Аксессуар
                  _buildCustomizeSection(
                    'Аксессуар',
                    Icons.auto_awesome_rounded,
                    _buildAccessoryRow(),
                  ),

                  // Фон
                  _buildCustomizeSection(
                    'Фон',
                    Icons.wallpaper_rounded,
                    _buildColorRow(
                      avatarBgColors,
                      _avatarData.bgColor,
                      (color) => setState(() => _avatarData = _avatarData.copyWith(bgColor: color)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Продолжить',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCustomizeSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppThemeColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildColorRow(List<Color> colors, Color selected, Function(Color) onSelect) {
    // SingleChildScrollView + Row — reliable tap handling on Flutter Web mobile
    // (ListView can swallow taps due to scroll gesture disambiguation)
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < colors.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _buildColorCircle(colors[i], colors[i].toARGB32() == selected.toARGB32(), onSelect),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, bool isSelected, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onSelect(color);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: _isLightColor(color) ? Colors.black54 : Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  Widget _buildHairStyleRow() {
    return SizedBox(
      height: 68,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < avatarHairStyles.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _buildHairStyleItem(avatarHairStyles[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHairStyleItem(String style) {
    final isSelected = _avatarData.hairStyle == style;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _avatarData = _avatarData.copyWith(hairStyle: style));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppThemeColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: AvatarWidget(
                avatarData: _avatarData.copyWith(hairStyle: style),
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hairStyleNames[style] ?? style,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accent
                    : AppThemeColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoryRow() {
    return SizedBox(
      height: 68,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < avatarAccessories.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _buildAccessoryItem(avatarAccessories[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(String accessory) {
    final isSelected = _avatarData.accessory == accessory;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _avatarData = _avatarData.copyWith(accessory: accessory));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppThemeColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: AvatarWidget(
                avatarData: _avatarData.copyWith(accessory: accessory),
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              accessoryNames[accessory] ?? accessory,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accent
                    : AppThemeColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === PAGE 2: Name ===
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Avatar preview
          AvatarWidget(avatarData: _avatarData, size: 100),

          const SizedBox(height: 24),

          Text(
            'Отлично!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.textPrimary(context),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Теперь давай познакомимся',
            style: TextStyle(
              fontSize: 16,
              color: AppThemeColors.textSecondary(context),
            ),
          ),

          const Spacer(flex: 2),

          // Name input
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Как тебя зовут?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Введи своё имя',
              filled: true,
              fillColor: AppThemeColors.surface(context),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.accent,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppThemeColors.border(context), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppThemeColors.border(context), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const Spacer(flex: 1),

          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isNotEmpty
                  ? _nextPage
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _nameController.text.trim().isNotEmpty
                    ? AppColors.accent
                    : AppThemeColors.disabled(context),
                foregroundColor: _nameController.text.trim().isNotEmpty
                    ? Colors.white
                    : AppThemeColors.disabledText(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Продолжить',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // === PAGE 3: Grade ===
  Widget _buildGradePage() {
    final descriptions = {
      1: 'Счёт, сложение, вычитание до 20',
      2: 'Умножение, деление, время и часы',
      3: 'Периметр, площадь, доли и дроби',
      4: 'Дроби, уравнения, скорость',
      5: 'Натуральные числа, дроби, проценты',
      6: 'Рациональные числа, пропорции',
      7: 'Алгебра, функции, геометрия',
      8: 'Квадратные уравнения, корни',
      9: 'Подготовка к ОГЭ',
      10: 'Тригонометрия, логарифмы',
      11: 'Подготовка к ЕГЭ',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Выбери класс',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Мы подберём подходящие задания',
            style: TextStyle(
                fontSize: 15,
                color: AppThemeColors.textSecondary(context)),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView(
              children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((grade) {
                final isSelected = _selectedGrade == grade;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedGrade = grade);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeColors.accentLight(context)
                            : AppThemeColors.surface(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppThemeColors.border(context),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppThemeColors.borderLight(context),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                '$grade',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : AppThemeColors.textPrimary(
                                          context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$grade класс',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppThemeColors.textPrimary(
                                            context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descriptions[grade] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        AppThemeColors.textSecondary(
                                            context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppThemeColors.border(context),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedGrade != null ? _finish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedGrade != null
                    ? AppColors.accent
                    : AppThemeColors.disabled(context),
                foregroundColor: _selectedGrade != null
                    ? Colors.white
                    : AppThemeColors.disabledText(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Начать обучение',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
