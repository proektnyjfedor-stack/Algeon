import 'dart:async';
import 'package:flutter/widgets.dart';

/// Refreshes date-dependent content without navigating or replacing a route.
/// Timers run only while this subtree is visible and the app is active.
mixin DayBoundaryObserver<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _dayTimer;
  bool _visible = false;
  bool _active = true;

  DateTime get dayClock;
  void onDayBoundary();

  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wasVisible = _visible;
    _visible = TickerMode.valuesOf(context).enabled;
    if (_visible && !wasVisible && _active) onDayBoundary();
    _scheduleDay();
  }

  void _scheduleDay() {
    _dayTimer?.cancel();
    _dayTimer = null;
    if (!mounted || !_visible || !_active) return;
    final now = dayClock;
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _dayTimer = Timer(midnight.difference(now), () {
      if (!mounted) return;
      onDayBoundary();
      _scheduleDay();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active && mounted) onDayBoundary();
    _scheduleDay();
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
