/// Main Screen -- adaptive shell for GoRouter tab navigation
///
/// Desktop (>=900px): expanded NavigationRail + content
/// Tablet  (600-899px): collapsed NavigationRail + content
/// Mobile  (<600px): floating Liquid Glass bottom nav with drag-to-switch

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/app_logo.dart';

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const List<_NavDestination> _destinations = [
  _NavDestination(
    label: 'Задачи',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    route: '/learn',
  ),
  _NavDestination(
    label: 'Практика',
    icon: Icons.bolt_outlined,
    activeIcon: Icons.bolt_rounded,
    route: '/practice',
  ),
  _NavDestination(
    label: 'Экзамены',
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment_rounded,
    route: '/exams',
  ),
  _NavDestination(
    label: 'Награды',
    icon: Icons.emoji_events_outlined,
    activeIcon: Icons.emoji_events_rounded,
    route: '/achievements',
  ),
  _NavDestination(
    label: 'Профиль',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    route: '/profile',
  ),
];

class MainScreen extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) return;
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return _buildDesktop(context);
    if (width >= 600) return _buildTablet(context);
    return _buildMobile(context);
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      color: AppThemeColors.background(context),
      child: Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: Row(
          children: [
            _buildNavigationRail(context, extended: true),
            VerticalDivider(width: 1, thickness: 1, color: AppThemeColors.border(context)),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Container(
      color: AppThemeColors.background(context),
      child: Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: Row(
          children: [
            _buildNavigationRail(context, extended: false),
            VerticalDivider(width: 1, thickness: 1, color: AppThemeColors.border(context)),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 64.0 + (bottomPadding > 0 ? bottomPadding : 16.0);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      extendBody: true,
      body: child,
      bottomNavigationBar: SizedBox(
        height: navHeight,
        child: _LiquidGlassNav(
          currentIndex: currentIndex,
          onTap: (index) => _onDestinationSelected(context, index),
          bottomPadding: bottomPadding,
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, {required bool extended}) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppThemeColors.surface(context),
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              extended: extended,
              backgroundColor: Colors.transparent,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onDestinationSelected(context, index),
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
              indicatorColor: AppThemeColors.accentLight(context),
              selectedIconTheme: IconThemeData(color: AppColors.accent, size: 26),
              unselectedIconTheme: IconThemeData(color: AppThemeColors.textHint(context), size: 24),
              selectedLabelTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
              unselectedLabelTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppThemeColors.textHint(context)),
              leading: extended
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const AppLogo(size: 32),
                        const SizedBox(width: 12),
                        Text('Algeon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppThemeColors.textPrimary(context), letterSpacing: -0.5)),
                      ]),
                    )
                  : const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: AppLogo(size: 32)),
              destinations: _destinations.map((d) => NavigationRailDestination(
                icon: Icon(d.icon), selectedIcon: Icon(d.activeIcon), label: Text(d.label),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: IconButton(
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: AppThemeColors.textSecondary(context), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Liquid Glass Nav с drag-to-switch
// ─────────────────────────────────────────────────────────────

class _LiquidGlassNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  const _LiquidGlassNav({
    required this.currentIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  @override
  State<_LiquidGlassNav> createState() => _LiquidGlassNavState();
}

class _LiquidGlassNavState extends State<_LiquidGlassNav>
    with SingleTickerProviderStateMixin {
  // --- анимация пилюли при tap-переходе ---
  late AnimationController _snapController;
  late Animation<double> _snapAnim;
  double _snapFrom = 0;
  double _snapTo = 0;
  // _committedX — последняя зафиксированная позиция (синхронизируется с currentIndex)
  double _committedX = 0;

  // --- drag state ---
  bool _isDragging = false;
  // pillX — абсолютная X-позиция левого края пилюли во время drag
  double _pillX = 0;
  double _itemWidth = 0;
  int _dragHoverIndex = -1; // таб под пилюлей прямо сейчас
  int _prevHoverIndex = -1; // для haptic только при смене

  int get _count => _destinations.length;

  double get _maxPillX => _itemWidth * (_count - 1);

  // Индекс таба под центром пилюли
  int _indexUnderPill(double pillLeftX) {
    if (_itemWidth <= 0) return widget.currentIndex;
    final center = pillLeftX + _itemWidth / 2;
    return (center / _itemWidth).floor().clamp(0, _count - 1);
  }

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _snapAnim = CurvedAnimation(parent: _snapController, curve: Curves.easeOutExpo);
    _snapAnim.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_LiquidGlassNav old) {
    super.didUpdateWidget(old);
    // Tap-переход: анимируем от текущей визуальной позиции к новой
    if (!_isDragging && old.currentIndex != widget.currentIndex) {
      _snapFrom = _currentPillX; // точная текущая визуальная позиция
      _snapTo = widget.currentIndex * _itemWidth;
      _committedX = _snapTo;
      _snapController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double get _currentPillX {
    if (_isDragging) return _pillX;
    if (_snapController.isAnimating) {
      return _snapFrom + (_snapTo - _snapFrom) * _snapAnim.value;
    }
    return _committedX;
  }

  void _onPanStart(DragStartDetails d) {
    _snapController.stop();
    // Начинаем drag с точной текущей визуальной позиции
    _pillX = _currentPillX;
    _dragHoverIndex = _indexUnderPill(_pillX);
    _prevHoverIndex = _dragHoverIndex;
    setState(() => _isDragging = true);
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      // Двигаем пилюлю 1:1 за пальцем, с мягкими упорами на краях
      _pillX = (_pillX + d.delta.dx).clamp(0.0, _maxPillX);

      final newHover = _indexUnderPill(_pillX);
      if (newHover != _dragHoverIndex) {
        _dragHoverIndex = newHover;
        if (newHover != _prevHoverIndex) {
          HapticFeedback.selectionClick();
          _prevHoverIndex = newHover;
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final landIndex = _indexUnderPill(_pillX);

    // Snap пилюли к ближайшему табу
    _snapFrom = _pillX;
    _snapTo = landIndex * _itemWidth;
    _committedX = _snapTo;
    _isDragging = false;
    _snapController.forward(from: 0);

    if (landIndex != widget.currentIndex) {
      HapticFeedback.mediumImpact();
      widget.onTap(landIndex);
    } else {
      setState(() {});
    }

    _dragHoverIndex = -1;
    _prevHoverIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = widget.bottomPadding > 0 ? widget.bottomPadding : 16.0;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          // Убран BackdropFilter: в Flutter Web CanvasKit он создаёт
          // невидимый слой, перехватывающий все тач-события на мобиле.
          // Используем полностью непрозрачный фон.
          color: isDark
              ? const Color(0xFF1C1C2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: LayoutBuilder(builder: (ctx, constraints) {
              _itemWidth = constraints.maxWidth / _count;
              // Инициализируем при первом build (itemWidth только теперь известен)
              if (_committedX == 0 && widget.currentIndex == 0) {
                // первый таб — всё верно
              } else if (!_isDragging && !_snapController.isAnimating) {
                // синхронизируем committedX если itemWidth изменился (ресайз)
                _committedX = widget.currentIndex * _itemWidth;
                _snapTo = _committedX;
              }

              final pillX = _currentPillX.clamp(0.0, _maxPillX);

              // Активный таб — тот под пилюлей во время drag, иначе widget.currentIndex
              final visualActiveIndex = _isDragging
                  ? _dragHoverIndex
                  : widget.currentIndex;

              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  children: [
                    // ── Пилюля ──
                    Positioned(
                      left: pillX + 6,
                      top: 8,
                      width: _itemWidth - 12,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accent.withValues(alpha: 0.28)
                              : AppColors.accent.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    // ── Nav items ──
                    Row(
                      children: List.generate(_count, (i) => _buildItem(
                        context: context,
                        index: i,
                        isDark: isDark,
                        visualActiveIndex: visualActiveIndex,
                      )),
                    ),
                  ],
                ),
              );
            }),
        ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required bool isDark,
    required int visualActiveIndex,
  }) {
    final isActive = visualActiveIndex == index;
    final dest = _destinations[index];

    final Color iconColor = isActive
        ? AppColors.accent
        : (isDark
            ? Colors.white.withValues(alpha: 0.45)
            : Colors.black.withValues(alpha: 0.38));

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isDragging) return;
          HapticFeedback.lightImpact();
          widget.onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isActive ? dest.activeIcon : dest.icon,
                  key: ValueKey('${index}_$isActive'),
                  color: iconColor,
                  size: isActive ? 25 : 23,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: iconColor,
                ),
                child: Text(dest.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
