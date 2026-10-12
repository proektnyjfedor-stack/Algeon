/// Main Screen -- adaptive shell for GoRouter tab navigation
///
/// Desktop (>=900px): expanded NavigationRail + content
/// Tablet  (600-899px): collapsed NavigationRail + content
/// Mobile  (<600px): floating Liquid Glass bottom nav with drag-to-switch
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class _NavDestination {
  const _NavDestination({
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

const List<_NavDestination> _destinations = [
  _NavDestination(
    labelKey: 'nav.learn',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    route: '/learn',
  ),
  _NavDestination(
    labelKey: 'nav.practice',
    icon: Icons.bolt_outlined,
    activeIcon: Icons.bolt_rounded,
    route: '/practice',
  ),
  _NavDestination(
    labelKey: 'nav.exams',
    icon: Icons.school_outlined,
    activeIcon: Icons.school_rounded,
    route: '/exams',
  ),
  _NavDestination(
    labelKey: 'nav.achievements',
    icon: Icons.emoji_events_outlined,
    activeIcon: Icons.emoji_events_rounded,
    route: '/achievements',
  ),
  _NavDestination(
    labelKey: 'nav.profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    route: '/profile',
  ),
];

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });
  final Widget child;
  final int currentIndex;

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) return;
    SoundService.hapticMedium();
    SoundService.playNavigate();
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageService>();
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return _buildDesktop(context, language);
    if (width >= 600) return _buildTablet(context, language);
    return _buildMobile(context, language);
  }

  Widget _buildDesktop(BuildContext context, LanguageService language) {
    return Container(
      color: AppThemeColors.background(context),
      child: Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: Row(
          children: [
            _buildNavigationRail(context, language, extended: true),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppThemeColors.border(context),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTablet(BuildContext context, LanguageService language) {
    return Container(
      color: AppThemeColors.background(context),
      child: Scaffold(
        backgroundColor: AppThemeColors.background(context),
        body: Row(
          children: [
            _buildNavigationRail(context, language, extended: false),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppThemeColors.border(context),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, LanguageService language) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 64.0 + (bottomPadding > 0 ? bottomPadding : 16.0);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      extendBody: true,
      body: _buildTabContent(),
      bottomNavigationBar: SizedBox(
        height: navHeight,
        child: _LiquidGlassNav(
          language: language,
          currentIndex: currentIndex,
          onTap: (index) => _onDestinationSelected(context, index),
          bottomPadding: bottomPadding,
        ),
      ),
    );
  }

  Widget _buildNavigationRail(
    BuildContext context,
    LanguageService language, {
    required bool extended,
  }) {
    final railWidth = extended ? 224.0 : 80.0;
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: railWidth,
      child: Container(
        color: AppThemeColors.surface(context),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (extended)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 24, 14, 12),
                  child: Row(
                    children: [
                      const AppLogo(size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Algeon',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.textPrimary(context),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: AppLogo(size: 32)),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(6, 4, 10, 16),
                  itemCount: _destinations.length,
                  itemBuilder: (ctx, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SidebarDestinationTile(
                      destination: _destinations[index],
                      language: language,
                      selected: index == currentIndex,
                      extended: extended,
                      primary: primary,
                      onTap: () => _onDestinationSelected(context, index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return RepaintBoundary(child: child);
  }
}

/// Пункт бокового меню: подсветка всей строки (иконка + текст), не только иконки.
class _SidebarDestinationTile extends StatelessWidget {
  const _SidebarDestinationTile({
    required this.destination,
    required this.language,
    required this.selected,
    required this.extended,
    required this.primary,
    required this.onTap,
  });
  final _NavDestination destination;
  final LanguageService language;
  final bool selected;
  final bool extended;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const noMotion = kIsWeb;
    final muted = AppThemeColors.textHint(context);
    final iconData = selected ? destination.activeIcon : destination.icon;
    final foreground = selected ? primary : muted;

    final tileDecoration = BoxDecoration(
      color: selected
          ? AppThemeColors.accentLight(context)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected ? primary.withValues(alpha: 0.35) : Colors.transparent,
      ),
    );

    return AnimatedContainer(
      duration: noMotion ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: tileDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: primary.withValues(alpha: 0.12),
          highlightColor: primary.withValues(alpha: 0.06),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? 11 : 8,
              vertical: extended ? 12 : 11,
            ),
            child: extended
                ? Row(
                    children: [
                      Icon(
                        iconData,
                        color: foreground,
                        size: selected ? 26 : 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          language.t(destination.labelKey),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: language.t(destination.labelKey),
                    child: Semantics(
                      label: language.t(destination.labelKey),
                      selected: selected,
                      button: true,
                      child: SizedBox(
                        height: 30,
                        child: Icon(iconData, color: foreground, size: 26),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Liquid Glass Nav с drag-to-switch
// ─────────────────────────────────────────────────────────────

class _LiquidGlassNav extends StatefulWidget {
  const _LiquidGlassNav({
    required this.language,
    required this.currentIndex,
    required this.onTap,
    required this.bottomPadding,
  });
  final LanguageService language;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

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
      duration: kIsWeb
          ? const Duration(milliseconds: 1)
          : const Duration(milliseconds: 380),
    );
    _snapAnim = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutExpo,
    );
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
      if (kIsWeb) {
        _snapController.stop();
      } else {
        _snapController.forward(from: 0);
      }
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
    SoundService.hapticLight();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      // Двигаем пилюлю 1:1 за пальцем, с мягкими упорами на краях
      _pillX = (_pillX + d.delta.dx).clamp(0.0, _maxPillX);

      final newHover = _indexUnderPill(_pillX);
      if (newHover != _dragHoverIndex) {
        _dragHoverIndex = newHover;
        if (newHover != _prevHoverIndex) {
          SoundService.hapticSelection();
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
      SoundService.hapticMedium();
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
    final isCompact = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          // Убран BackdropFilter: в Flutter Web CanvasKit он создаёт
          // невидимый слой, перехватывающий все тач-события на мобиле.
          // Используем полностью непрозрачный фон.
          color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
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
              blurRadius: isCompact ? 14 : 32,
              offset: Offset(0, isCompact ? 4 : 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
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
              onPanStart: kIsWeb ? null : _onPanStart,
              onPanUpdate: kIsWeb ? null : _onPanUpdate,
              onPanEnd: kIsWeb ? null : _onPanEnd,
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
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.28)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                  // ── Nav items ──
                  Row(
                    children: List.generate(
                      _count,
                      (i) => _buildItem(
                        context: context,
                        index: i,
                        isDark: isDark,
                        isCompact: isCompact,
                        visualActiveIndex: visualActiveIndex,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required bool isDark,
    required bool isCompact,
    required int visualActiveIndex,
  }) {
    const noMotion = kIsWeb;
    final isActive = visualActiveIndex == index;
    final dest = _destinations[index];

    final Color iconColor = isActive
        ? Theme.of(context).colorScheme.primary
        : (isDark
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.black.withValues(alpha: 0.38));

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isDragging) return;
          SoundService.hapticLight();
          widget.onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: noMotion
                    ? Duration.zero
                    : Duration(milliseconds: isCompact ? 90 : 180),
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
                duration: noMotion
                    ? Duration.zero
                    : Duration(milliseconds: isCompact ? 90 : 180),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: iconColor,
                ),
                child: Text(
                  widget.language.t(dest.labelKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
