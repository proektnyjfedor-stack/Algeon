/// Sound Service — звуковые эффекты из [assets/sounds] и тактильный отклик.
///
/// Звуки включаются настройкой «Звуки» в профиле. Вибрация всегда на поддерживаемых платформах.
library;

import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  SoundService._();

  static SharedPreferences? _prefs;
  static const String _keySoundEnabled = 'sound_enabled';

  static final AudioCache _audioCache = AudioCache(prefix: 'assets/sounds/');
  static final Map<String, AudioPool> _pools = <String, AudioPool>{};
  static final Map<String, Future<AudioPool?>> _poolFutures =
      <String, Future<AudioPool?>>{};
  static final Random _rng = Random();
  static final Map<String, int> _lastPlayedAtMs = <String, int>{};
  static bool _interactionPrimed = false;

  /// Чуть ниже единицы — меньше клиппинг при наложении коротких сэмплов.
  static const double _masterVolume = 0.88;

  /// Небольшой пул снижает память и лаги в браузере. UI-звуки всё равно
  /// ограничены через minGapMs, поэтому большой пул не нужен.
  static const int _uiPoolSize = 4;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static AudioContext _sfxContext() {
    return AudioContext(
      android: const AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );
  }

  static Future<AudioPool?> _createPool(String file) async {
    try {
      final ctx = !kIsWeb ? _sfxContext() : null;
      final isFrequentUiSound =
          file == 'tap.wav' || file == 'navigate.wav' || file == 'next.wav';
      return AudioPool.create(
        source: AssetSource(file),
        audioCache: _audioCache,
        audioContext: ctx,
        minPlayers: isFrequentUiSound ? 2 : 1,
        maxPlayers: isFrequentUiSound ? _uiPoolSize : 2,
      );
    } catch (e, st) {
      debugPrint('SoundService._createPool($file): $e\n$st');
      return null;
    }
  }

  static Future<AudioPool?> _getPool(String file) async {
    final existing = _pools[file];
    if (existing != null) return existing;
    final future = _poolFutures[file] ??= _createPool(file);
    final pool = await future;
    if (pool != null) {
      _pools[file] = pool;
    }
    return pool;
  }

  static void notifyUserInteraction() {
    if (_interactionPrimed) return;
    _interactionPrimed = true;
    if (!kIsWeb) return;
    unawaited(_primeWebAudioUnlock());
  }

  static Future<void> _primeWebAudioUnlock() async {
    final pool = await _getPool('tap.wav');
    if (pool == null) return;
    try {
      final stop = await pool.start(volume: 0);
      await Future<void>.delayed(const Duration(milliseconds: 8));
      await stop();
    } catch (_) {}
  }

  static bool isSoundEnabled() {
    return _prefs?.getBool(_keySoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySoundEnabled, enabled);
  }

  static Future<void> _playAsset(
    String file, {
    double volume = 1.0,
    int minGapMs = 0,
    bool humanize = false,
  }) async {
    if (!isSoundEnabled()) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayedAtMs[file];
    if (minGapMs > 0 && last != null && now - last < minGapMs) return;
    _lastPlayedAtMs[file] = now;

    final pool = await _getPool(file);
    if (pool == null) return;

    try {
      final volJitter = humanize ? ((_rng.nextDouble() - 0.5) * 0.075) : 0.0;
      final mixedVolume = (volume * _masterVolume + volJitter).clamp(0.0, 1.0);

      // AudioPool держит source уже установленным. Для коротких web-SFX это
      // заметно стабильнее, чем заново создавать BytesSource на каждый тап.
      await pool.start(volume: mixedVolume);
    } catch (e, st) {
      debugPrint('SoundService: $file — $e\n$st');
    }
  }

  static void _fire(
    String file, {
    double volume = 1.0,
    int minGapMs = 0,
    bool humanize = false,
  }) {
    unawaited(
      _playAsset(
        file,
        volume: volume,
        minGapMs: minGapMs,
        humanize: humanize,
      ),
    );
  }

  static void _vibrate({bool heavy = false}) {
    if (kIsWeb) return;
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  // ── Ответы и прогресс ──

  static Future<void> playCorrect() async {
    _fire(
      'correct.wav',
      volume: 0.95,
    );
    _vibrate();
  }

  static Future<void> playWrong() async {
    _fire(
      'wrong.wav',
      volume: 0.9,
    );
    _vibrate(heavy: true);
  }

  static Future<void> playStreak() async {
    _fire(
      'streak.wav',
      volume: 0.94,
    );
    _vibrate();
  }

  static Future<void> playAchievement() async {
    _fire(
      'achievement.wav',
      volume: 0.96,
    );
    _vibrate();
  }

  static Future<void> playComplete() async {
    _fire(
      'complete.wav',
      volume: 0.98,
    );
    _vibrate();
  }

  // ── UI (короткие) ──

  static void playTap() {
    notifyUserInteraction();
    _fire(
      'tap.wav',
      volume: 0.44,
      minGapMs: 42,
      humanize: true,
    );
  }

  static void playKey() {
    notifyUserInteraction();
    _fire(
      'tap.wav',
      volume: 0.36,
      minGapMs: 18,
      humanize: true,
    );
  }

  static void playNavigate() {
    notifyUserInteraction();
    _fire(
      'navigate.wav',
      volume: 0.66,
      minGapMs: 72,
    );
  }

  static void playPop() {
    notifyUserInteraction();
    _fire(
      'pop.wav',
      volume: 0.58,
      minGapMs: 72,
    );
  }

  static void playStart() {
    notifyUserInteraction();
    _fire(
      'start.wav',
      volume: 0.78,
      minGapMs: 100,
    );
  }

  static void playNext() {
    notifyUserInteraction();
    _fire(
      'next.wav',
      volume: 0.64,
      minGapMs: 64,
    );
  }

  // ── Только тактильно (Safari на iPhone вибрацию с сайта не даёт) ──

  static void hapticLight() {
    if (kIsWeb) return;
    HapticFeedback.lightImpact();
  }

  static void hapticMedium() {
    if (kIsWeb) return;
    HapticFeedback.mediumImpact();
  }

  static void hapticHeavy() {
    if (kIsWeb) return;
    HapticFeedback.heavyImpact();
  }

  static void hapticSelection() {
    if (kIsWeb) return;
    HapticFeedback.selectionClick();
  }

  static Future<void> hapticDouble() async {
    if (kIsWeb) return;
    HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 58));
    HapticFeedback.lightImpact();
  }

  static Future<void> hapticBurst({int steps = 6}) async {
    if (kIsWeb) return;
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
