/// Onboarding — Кастомизация персонажа, имя, класс
///
/// 3 шага без выбора пола
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../widgets/avatars.dart';

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

  bool get _isLandscape {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  void _randomizeAvatar() {
    SoundService.hapticLight();
    SoundService.playTap();
    final time = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _avatarData = _avatarData.copyWith(
        id: 'custom',
        skinColor: avatarSkinColors[time % avatarSkinColors.length],
        hairStyle: avatarHairStyles[(time ~/ 3) % avatarHairStyles.length],
        hairColor: avatarHairColors[(time ~/ 5) % avatarHairColors.length],
        shirtColor: avatarShirtColors[(time ~/ 7) % avatarShirtColors.length],
        accessory: avatarAccessories[(time ~/ 11) % avatarAccessories.length],
        expression: avatarExpressions[(time ~/ 13) % avatarExpressions.length],
        bgColor: avatarBgColors[(time ~/ 17) % avatarBgColors.length],
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      SoundService.playNavigate();
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      SoundService.playTap();
      setState(() => _currentPage--);
    }
  }

  Future<void> _skip() async {
    SoundService.playNavigate();
    final isEn = context.read<LanguageService>().isEnglish;
    await ProgressService.setUserName(isEn ? 'Student' : 'Ученик');
    await ProgressService.setAvatar('boy_blue');
    await ProgressService.setCurrentGrade(5);
    await ProgressService.setOnboardingComplete(true);

    if (!mounted) return;
    context.go('/learn');
  }

  Future<void> _finish() async {
    SoundService.playComplete();
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ProgressService.setUserName(name);
    }
    await ProgressService.setCustomAvatar(_avatarData.toMap());
    await ProgressService.setCurrentGrade(_selectedGrade ?? 5);
    await ProgressService.setOnboardingComplete(true);

    if (!mounted) return;
    context.go('/learn');
  }

  @override
  Widget build(BuildContext context) {
    final landscape = _isLandscape;
    final lang = context.watch<LanguageService>();
    final t = lang.t;
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
                  padding: EdgeInsets.fromLTRB(landscape ? 16 : 24,
                      landscape ? 10 : 16, landscape ? 16 : 24, 0),
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
                      SizedBox(width: landscape ? 10 : 16),
                      Expanded(child: _buildProgressDots()),
                      SizedBox(width: landscape ? 4 : 8),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          t('onboarding.skip'),
                          style: TextStyle(
                            fontSize: landscape ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textHint(context),
                          ),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<AppLanguage>(
                          value: lang.language,
                          onChanged: (value) {
                            if (value == null) return;
                            lang.setLanguage(value);
                          },
                          items: [
                            DropdownMenuItem(
                              value: AppLanguage.ru,
                              child: Text(t('lang.ru')),
                            ),
                            DropdownMenuItem(
                              value: AppLanguage.en,
                              child: Text(t('lang.en')),
                            ),
                          ],
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
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? AppColors.accent
                  : AppThemeColors.borderLight(context),
            ),
          ),
        );
      }),
    );
  }

  /// Мягкая карточка-шапка — единый стиль шагов онбординга.
  Widget _onboardingSoftHeader(List<Widget> children) {
    final landscape = _isLandscape;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: landscape ? 14 : 18,
        horizontal: landscape ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppThemeColors.accentLight(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  // === PAGE 1: Customize Character ===
  Widget _buildCustomizePage() {
    final t = context.watch<LanguageService>().t;
    final landscape = _isLandscape;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: landscape ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: landscape ? 8 : 16),

          _onboardingSoftHeader([
            Icon(
              Icons.auto_awesome_rounded,
              size: landscape ? 26 : 30,
              color: AppColors.accent,
            ),
            SizedBox(height: landscape ? 6 : 8),
            Text(
              context.watch<LanguageService>().t('onboarding.customizeTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: landscape ? 14 : 15,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ]),

          SizedBox(height: landscape ? 10 : 20),

          // Avatar preview
          Container(
            padding: EdgeInsets.all(landscape ? 10 : 12),
            decoration: BoxDecoration(
              color: AppThemeColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppThemeColors.border(context)),
              boxShadow: AppShadows.soft(context),
            ),
            child: AvatarWidget(
                avatarData: _avatarData, size: landscape ? 82 : 96),
          ),

          SizedBox(height: landscape ? 10 : 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _randomizeAvatar,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                  label: Text(context.watch<LanguageService>().t('onboarding.random')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSelectionChip(
                context.watch<LanguageService>().t('onboarding.hair'),
                hairStyleNames[_avatarData.hairStyle] ?? _avatarData.hairStyle,
              ),
              _buildSelectionChip(
                context.watch<LanguageService>().t('onboarding.expression'),
                expressionNames[_avatarData.expression] ?? _avatarData.expression,
              ),
              _buildSelectionChip(
                context.watch<LanguageService>().t('onboarding.accessory'),
                accessoryNames[_avatarData.accessory] ?? _avatarData.accessory,
              ),
            ],
          ),
          SizedBox(height: landscape ? 8 : 10),

          // Customization options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Причёска
                  _buildCustomizeSection(
                    t('onboarding.hair'),
                    Icons.content_cut_rounded,
                    _buildHairStyleRow(),
                  ),

                  _buildCustomizeSection(
                    t('onboarding.expression'),
                    Icons.emoji_emotions_rounded,
                    _buildExpressionRow(),
                  ),

                  // Цвет кожи
                  _buildCustomizeSection(
                    t('onboarding.skin'),
                    Icons.palette_rounded,
                    _buildColorRow(
                      avatarSkinColors,
                      _avatarData.skinColor,
                      (color) => setState(() =>
                          _avatarData = _avatarData.copyWith(skinColor: color)),
                    ),
                  ),

                  // Цвет волос
                  _buildCustomizeSection(
                    t('onboarding.hairColor'),
                    Icons.brush_rounded,
                    _buildColorRow(
                      avatarHairColors,
                      _avatarData.hairColor,
                      (color) => setState(() =>
                          _avatarData = _avatarData.copyWith(hairColor: color)),
                    ),
                  ),

                  // Цвет одежды
                  _buildCustomizeSection(
                    t('onboarding.clothes'),
                    Icons.checkroom_rounded,
                    _buildColorRow(
                      avatarShirtColors,
                      _avatarData.shirtColor,
                      (color) => setState(() => _avatarData =
                          _avatarData.copyWith(shirtColor: color)),
                    ),
                  ),

                  // Аксессуар
                  _buildCustomizeSection(
                    t('onboarding.accessory'),
                    Icons.auto_awesome_rounded,
                    _buildAccessoryRow(),
                  ),

                  // Фон
                  _buildCustomizeSection(
                    t('onboarding.background'),
                    Icons.wallpaper_rounded,
                    _buildColorRow(
                      avatarBgColors,
                      _avatarData.bgColor,
                      (color) => setState(() =>
                          _avatarData = _avatarData.copyWith(bgColor: color)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: landscape ? 8 : 12),

          SizedBox(
            width: double.infinity,
            height: landscape ? 50 : 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.watch<LanguageService>().t('common.continue'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: landscape ? 10 : 16),
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
              Icon(icon,
                  size: 16, color: AppThemeColors.textSecondary(context)),
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

  Widget _buildSelectionChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeColors.borderLight(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Text(
        '$title: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppThemeColors.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildColorRow(
      List<Color> colors, Color selected, Function(Color) onSelect) {
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
              _buildColorCircle(colors[i],
                  colors[i].toARGB32() == selected.toARGB32(), onSelect),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(
      Color color, bool isSelected, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () {
        SoundService.hapticLight();
        SoundService.playTap();
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
              ? [
                  BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1)
                ]
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
      height: 76,
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
        SoundService.hapticLight();
        SoundService.playTap();
        setState(() => _avatarData = _avatarData.copyWith(hairStyle: style));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.accent : AppThemeColors.border(context),
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
                fontSize: 11,
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
      height: 76,
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

  Widget _buildExpressionRow() {
    return SizedBox(
      height: 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < avatarExpressions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _buildExpressionItem(avatarExpressions[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpressionItem(String expression) {
    final isSelected = _avatarData.expression == expression;
    return GestureDetector(
      onTap: () {
        SoundService.hapticLight();
        SoundService.playTap();
        setState(
            () => _avatarData = _avatarData.copyWith(expression: expression));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppThemeColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.accent : AppThemeColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          expressionNames[expression] ?? expression,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.accent
                : AppThemeColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(String accessory) {
    final isSelected = _avatarData.accessory == accessory;
    return GestureDetector(
      onTap: () {
        SoundService.hapticLight();
        SoundService.playTap();
        setState(
            () => _avatarData = _avatarData.copyWith(accessory: accessory));
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
            color:
                isSelected ? AppColors.accent : AppThemeColors.border(context),
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
    final landscape = _isLandscape;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: landscape ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: landscape ? 8 : 16),

          _onboardingSoftHeader([
            AvatarWidget(avatarData: _avatarData, size: landscape ? 82 : 100),
            SizedBox(height: landscape ? 12 : 16),
            Text(
              context.watch<LanguageService>().t('onboarding.great'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: landscape ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            SizedBox(height: landscape ? 6 : 8),
            Text(
              context.watch<LanguageService>().t('onboarding.letsMeet'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: landscape ? 14 : 16,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ]),

          SizedBox(height: landscape ? 14 : 22),

          // Name input
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.watch<LanguageService>().t('onboarding.whatsName'),
              style: TextStyle(
                fontSize: landscape ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
          ),
          SizedBox(height: landscape ? 8 : 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              fontSize: landscape ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: context.watch<LanguageService>().t('onboarding.enterName'),
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
                borderSide:
                    BorderSide(color: AppThemeColors.border(context), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: AppThemeColors.border(context), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: landscape ? 14 : 18),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const Spacer(),

          // Button
          SizedBox(
            width: double.infinity,
            height: landscape ? 50 : 56,
            child: ElevatedButton(
              onPressed:
                  _nameController.text.trim().isNotEmpty ? _nextPage : null,
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
              child: Text(
                context.watch<LanguageService>().t('common.continue'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: landscape ? 12 : 16),
        ],
      ),
    );
  }

  // === PAGE 3: Grade ===
  Widget _buildGradePage() {
    final landscape = _isLandscape;
    final isEn = context.watch<LanguageService>().isEnglish;
    final descriptions = isEn
        ? {
            5: 'Natural numbers, fractions, percentages',
            6: 'Rational numbers, proportions',
            7: 'Algebra, functions, geometry',
            8: 'Quadratic equations, roots',
            9: 'Functions, progressions, combinatorics',
            10: 'Trigonometry, logarithms',
            11: 'Advanced algebra and analysis',
          }
        : {
            5: 'Натуральные числа, дроби, проценты',
            6: 'Рациональные числа, пропорции',
            7: 'Алгебра, функции, геометрия',
            8: 'Квадратные уравнения, корни',
            9: 'Функции, прогрессии, комбинаторика',
            10: 'Тригонометрия, логарифмы',
            11: 'Продвинутая алгебра и анализ',
          };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: landscape ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: landscape ? 8 : 16),
          _onboardingSoftHeader([
            Icon(
              Icons.school_rounded,
              color: AppColors.accent,
              size: landscape ? 32 : 36,
            ),
            SizedBox(height: landscape ? 8 : 10),
            Text(
              context.watch<LanguageService>().t('onboarding.pickGrade'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: landscape ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            SizedBox(height: landscape ? 6 : 8),
            Text(
              context.watch<LanguageService>().t('onboarding.pickGradeSub'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: landscape ? 14 : 15,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
          ]),
          SizedBox(height: landscape ? 14 : 24),
          Expanded(
            child: ListView(
              children: [5, 6, 7, 8, 9, 10, 11].map((grade) {
                final isSelected = _selectedGrade == grade;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      SoundService.hapticLight();
                      SoundService.playTap();
                      setState(() => _selectedGrade = grade);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(landscape ? 14 : 20),
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
                            height: landscape ? 46 : 52,
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
                                  fontSize: landscape ? 21 : 24,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : AppThemeColors.textPrimary(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: landscape ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.watch<LanguageService>().isEnglish
                                      ? 'Grade $grade'
                                      : '$grade класс',
                                  style: TextStyle(
                                    fontSize: landscape ? 16 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppThemeColors.textPrimary(context),
                                  ),
                                ),
                                SizedBox(height: landscape ? 2 : 4),
                                Text(
                                  descriptions[grade] ?? '',
                                  style: TextStyle(
                                    fontSize: landscape ? 13 : 14,
                                    color:
                                        AppThemeColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
            height: landscape ? 50 : 56,
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
              child: Text(
                context.watch<LanguageService>().t('onboarding.startLearning'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: landscape ? 12 : 32),
        ],
      ),
    );
  }
}
