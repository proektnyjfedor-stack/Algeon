/// Sound Service — звуковые эффекты из [assets/sounds] и тактильный отклик.
///
/// Звуки включаются настройкой «Звуки» в профиле. Вибрация всегда на поддерживаемых платформах.
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();

  static SharedPreferences? _prefs;
  static const String _keySoundEnabled = 'sound_enabled';

  static final List<AudioPlayer> _pool = [];
  static int _poolIndex = 0;
  static bool _audioReady = false;
  static Future<void>? _poolInitFuture;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Пул AudioPlayer нельзя создавать синхронно в main() до runApp: на Web
    // await setReleaseMode часто блокирует до первого кадра — в index.html
    // вечно видна только надпись «Algeon».
    _poolInitFuture ??= _initAudioPool();
  }

  static Future<void> _initAudioPool() async {
    if (_audioReady) return;
    try {
      for (var i = 0; i < 8; i++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        _pool.add(p);
      }
      _audioReady = true;
    } catch (e, st) {
      debugPrint('SoundService._initAudioPool: $e\n$st');
    }
  }

  static Future<void> _ensurePoolLoaded() async {
    final f = _poolInitFuture;
    if (f != null) {
      try {
        await f;
      } catch (_) {}
    }
  }

  static bool isSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }

  static Future<void> _playAsset(String file, {double volume = 1.0}) async {
    if (!isSoundEnabled()) return;
    await _ensurePoolLoaded();
    if (!_audioReady || _pool.isEmpty) return;
    final p = _pool[_poolIndex % _pool.length];
    _poolIndex++;
    try {
      await p.setVolume(volume.clamp(0.0, 1.0));
      await p.stop();
      await p.play(AssetSource('sounds/$file'));
    } catch (e, st) {
      debugPrint('SoundService: $file — $e\n$st');
    }
  }

  static void _fire(String file, {double volume = 1.0}) {
    unawaited(_playAsset(file, volume: volume));
  }

  static void _vibrate({bool heavy = false}) {
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  // ── Ответы и прогресс ──

  static Future<void> playCorrect() async {
    _fire('correct.wav');
    _vibrate();
  }

  static Future<void> playWrong() async {
    _fire('wrong.wav', volume: 1.0);
    _vibrate(heavy: true);
  }

  static Future<void> playStreak() async {
    _fire('streak.wav');
    _vibrate();
  }

  static Future<void> playAchievement() async {
    _fire('achievement.wav');
    _vibrate();
  }

  static Future<void> playComplete() async {
    _fire('complete.wav');
    _vibrate();
  }

  // ── UI (короткие) ──

  static void playTap() => _fire('tap.wav');

  static void playKey() => _fire('tap.wav', volume: 0.38);

  static void playNavigate() => _fire('navigate.wav');

  static void playPop() => _fire('pop.wav');

  static void playStart() => _fire('start.wav');

  static void playNext() => _fire('next.wav');

  // ── Только тактильно (Safari на iPhone вибрацию с сайта не даёт) ──

  static void hapticLight() => HapticFeedback.lightImpact();

  static void hapticMedium() => HapticFeedback.mediumImpact();

  static void hapticHeavy() => HapticFeedback.heavyImpact();

  static void hapticSelection() => HapticFeedback.selectionClick();

  static Future<void> hapticDouble() async {
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 58));
    HapticFeedback.lightImpact();
  }

  static Future<void> hapticBurst({int steps = 6}) async {
    for (var i = 0; i < steps; i++) {
      if (i.isEven) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.lightImpact();
      }
      await Future<void>.delayed(const Duration(milliseconds: 26));
    }
    HapticFeedback.mediumImpact();
  }
}
