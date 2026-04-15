library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'progress_service.dart';

enum DropKind { profileBackground, coins, skin }

class DropReward {
  const DropReward({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.coins = 0,
    required this.createdAtMs,
  });

  final DropKind kind;
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int coins;
  final int createdAtMs;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'color': color.toARGB32(),
        'coins': coins,
        'createdAtMs': createdAtMs,
      };

  static DropReward fromMap(Map<String, dynamic> map) {
    final kindName = map['kind'] as String? ?? DropKind.coins.name;
    final kind = DropKind.values.firstWhere(
      (k) => k.name == kindName,
      orElse: () => DropKind.coins,
    );
    return DropReward(
      kind: kind,
      id: map['id'] as String? ?? 'unknown',
      title: map['title'] as String? ?? 'Награда',
      subtitle: map['subtitle'] as String? ?? '',
      icon: _iconForKind(kind),
      color: Color(map['color'] as int? ?? const Color(0xFF3B82F6).toARGB32()),
      coins: map['coins'] as int? ?? 0,
      createdAtMs: map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static IconData _iconForKind(DropKind kind) {
    switch (kind) {
      case DropKind.profileBackground:
        return Icons.wallpaper_rounded;
      case DropKind.coins:
        return Icons.monetization_on_rounded;
      case DropKind.skin:
        return Icons.style_rounded;
    }
  }
}

class DropSkinItem {
  const DropSkinItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _DropItemDef {
  const _DropItemDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class RewardDropService {
  static SharedPreferences? _prefs;
  static final Random _random = Random();

  static const String _keyUnlockedSkins = 'drop_unlocked_skins';
  static const String _keyUnlockedBackgrounds = 'drop_unlocked_backgrounds';
  static const String _keyHistory = 'drop_history_v1';

  static Set<String> _unlockedSkins = <String>{};
  static Set<String> _unlockedBackgrounds = <String>{};
  static final List<DropReward> _history = <DropReward>[];

  static const List<_DropItemDef> _backgroundPool = [
    _DropItemDef(
      id: 'bg_neon_city',
      title: 'Фон: Неон-город',
      subtitle: 'Яркий ночной фон профиля',
      icon: Icons.location_city_rounded,
      color: Color(0xFF7C3AED),
    ),
    _DropItemDef(
      id: 'bg_galaxy',
      title: 'Фон: Галактика',
      subtitle: 'Космический профильный фон',
      icon: Icons.nightlight_round,
      color: Color(0xFF0EA5E9),
    ),
    _DropItemDef(
      id: 'bg_sunset',
      title: 'Фон: Закат',
      subtitle: 'Теплый закатный стиль',
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFFF97316),
    ),
    _DropItemDef(
      id: 'bg_aurora',
      title: 'Фон: Аврора',
      subtitle: 'Холодное северное сияние',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF14B8A6),
    ),
    _DropItemDef(
      id: 'bg_volcano',
      title: 'Фон: Вулкан',
      subtitle: 'Огненный стиль профиля',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFDC2626),
    ),
    _DropItemDef(
      id: 'bg_cyber_grid',
      title: 'Фон: Кибер-сетка',
      subtitle: 'Технологичный синий фон',
      icon: Icons.grid_4x4_rounded,
      color: Color(0xFF2563EB),
    ),
  ];

  static const List<_DropItemDef> _skinPool = [
    _DropItemDef(id: 'skin_cosmo_captain', title: 'Скин: Космо-капитан', subtitle: 'Костюм защитника орбиты', icon: Icons.shield_rounded, color: Color(0xFF2563EB)),
    _DropItemDef(id: 'skin_thunder_hero', title: 'Скин: Громовой герой', subtitle: 'Плащ и энергия молний', icon: Icons.flash_on_rounded, color: Color(0xFFF59E0B)),
    _DropItemDef(id: 'skin_web_runner', title: 'Скин: Паутинный раннер', subtitle: 'Ловкий городской костюм', icon: Icons.sports_martial_arts_rounded, color: Color(0xFFEF4444)),
    _DropItemDef(id: 'skin_night_detective', title: 'Скин: Ночной детектив', subtitle: 'Маска и темный плащ', icon: Icons.dark_mode_rounded, color: Color(0xFF374151)),
    _DropItemDef(id: 'skin_iron_mind', title: 'Скин: Железный разум', subtitle: 'Техно-броня из будущего', icon: Icons.memory_rounded, color: Color(0xFF6B7280)),
    _DropItemDef(id: 'skin_starlight_guard', title: 'Скин: Звездный страж', subtitle: 'Космический шлем и форма', icon: Icons.stars_rounded, color: Color(0xFF8B5CF6)),
    _DropItemDef(id: 'skin_speed_dash', title: 'Скин: Скоростной дэш', subtitle: 'Спортивный супер-костюм', icon: Icons.bolt_rounded, color: Color(0xFFF97316)),
    _DropItemDef(id: 'skin_frost_mage', title: 'Скин: Ледяной маг', subtitle: 'Холодный плащ и кристалл', icon: Icons.ac_unit_rounded, color: Color(0xFF0EA5E9)),
    _DropItemDef(id: 'skin_blaze_knight', title: 'Скин: Пламенный рыцарь', subtitle: 'Доспех огня и света', icon: Icons.local_fire_department_rounded, color: Color(0xFFEA580C)),
    _DropItemDef(id: 'skin_shadow_ninja', title: 'Скин: Теневой ниндзя', subtitle: 'Скрытный костюм ночи', icon: Icons.visibility_off_rounded, color: Color(0xFF1F2937)),
    _DropItemDef(id: 'skin_tech_hacker', title: 'Скин: Техно-хакер', subtitle: 'Неон и киберочки', icon: Icons.terminal_rounded, color: Color(0xFF10B981)),
    _DropItemDef(id: 'skin_forest_ranger', title: 'Скин: Лесной рейнджер', subtitle: 'Лук и зелёная броня', icon: Icons.nature_people_rounded, color: Color(0xFF16A34A)),
    _DropItemDef(id: 'skin_desert_nomad', title: 'Скин: Пустынный номад', subtitle: 'Плащ и очки песков', icon: Icons.wb_sunny_rounded, color: Color(0xFFD97706)),
    _DropItemDef(id: 'skin_ocean_watcher', title: 'Скин: Океанский страж', subtitle: 'Волны и морская броня', icon: Icons.waves_rounded, color: Color(0xFF0284C7)),
    _DropItemDef(id: 'skin_light_paladin', title: 'Скин: Паладин света', subtitle: 'Золотой щит и эмблема', icon: Icons.workspace_premium_rounded, color: Color(0xFFEAB308)),
    _DropItemDef(id: 'skin_crystal_archer', title: 'Скин: Кристальный лучник', subtitle: 'Сияющий доспех', icon: Icons.auto_awesome_rounded, color: Color(0xFF22C55E)),
    _DropItemDef(id: 'skin_urban_legend', title: 'Скин: Городская легенда', subtitle: 'Стрит-стиль и капюшон', icon: Icons.hiking_rounded, color: Color(0xFF3B82F6)),
    _DropItemDef(id: 'skin_galactic_pilot', title: 'Скин: Галактический пилот', subtitle: 'Шлем, перчатки, ранцы', icon: Icons.rocket_launch_rounded, color: Color(0xFF6366F1)),
    _DropItemDef(id: 'skin_arcane_sage', title: 'Скин: Аркан-сейдж', subtitle: 'Мантия и магические руны', icon: Icons.menu_book_rounded, color: Color(0xFF7C3AED)),
    _DropItemDef(id: 'skin_metal_guard', title: 'Скин: Металл-гвард', subtitle: 'Тяжёлая защита', icon: Icons.hardware_rounded, color: Color(0xFF4B5563)),
    _DropItemDef(id: 'skin_stage_star', title: 'Скин: Звезда сцены', subtitle: 'Блестящий концертный образ', icon: Icons.mic_rounded, color: Color(0xFFEC4899)),
    _DropItemDef(id: 'skin_beat_master', title: 'Скин: Бит-мастер', subtitle: 'Наушники и ритм', icon: Icons.headphones_rounded, color: Color(0xFF8B5CF6)),
    _DropItemDef(id: 'skin_silver_voice', title: 'Скин: Серебряный голос', subtitle: 'Легендарный сценический лук', icon: Icons.music_note_rounded, color: Color(0xFF64748B)),
    _DropItemDef(id: 'skin_gold_icon', title: 'Скин: Золотой айкон', subtitle: 'Премиум-стиль знаменитости', icon: Icons.emoji_events_rounded, color: Color(0xFFF59E0B)),
    _DropItemDef(id: 'skin_action_star', title: 'Скин: Экшн-легенда', subtitle: 'Куртка и культовые очки', icon: Icons.movie_rounded, color: Color(0xFFDC2626)),
    _DropItemDef(id: 'skin_fashion_prime', title: 'Скин: Фэшн-прайм', subtitle: 'Подиумный образ', icon: Icons.style_rounded, color: Color(0xFFDB2777)),
    _DropItemDef(id: 'skin_streamer_pro', title: 'Скин: Стример-про', subtitle: 'Неон и игровая аура', icon: Icons.live_tv_rounded, color: Color(0xFF06B6D4)),
    _DropItemDef(id: 'skin_champion', title: 'Скин: Чемпион', subtitle: 'Форма победителя', icon: Icons.sports_soccer_rounded, color: Color(0xFF16A34A)),
    _DropItemDef(id: 'skin_mecha_zero', title: 'Скин: Меха-Ноль', subtitle: 'Футуристическая броня', icon: Icons.precision_manufacturing_rounded, color: Color(0xFF0F172A)),
    _DropItemDef(id: 'skin_royal_guard', title: 'Скин: Королевский страж', subtitle: 'Парадная форма и знаки', icon: Icons.military_tech_rounded, color: Color(0xFFB45309)),
    _DropItemDef(id: 'skin_astro_idol', title: 'Скин: Астро-идол', subtitle: 'Космо-поп стиль', icon: Icons.album_rounded, color: Color(0xFF9333EA)),
    _DropItemDef(id: 'skin_captain_wave', title: 'Скин: Капитан волны', subtitle: 'Морской героический образ', icon: Icons.sailing_rounded, color: Color(0xFF0284C7)),
    _DropItemDef(id: 'skin_phantom', title: 'Скин: Фантом', subtitle: 'Призрачный stealth-костюм', icon: Icons.blur_on_rounded, color: Color(0xFF334155)),
    _DropItemDef(id: 'skin_sunbreaker', title: 'Скин: Санбрейкер', subtitle: 'Солнечная энергия', icon: Icons.light_mode_rounded, color: Color(0xFFF59E0B)),
    _DropItemDef(id: 'skin_moonblade', title: 'Скин: Лунный клинок', subtitle: 'Серебристый ночной стиль', icon: Icons.brightness_2_rounded, color: Color(0xFF94A3B8)),
    _DropItemDef(id: 'skin_neo_ronin', title: 'Скин: Нео-ронин', subtitle: 'Киберсамурай в неоне', icon: Icons.gesture_rounded, color: Color(0xFF22C55E)),
    _DropItemDef(id: 'skin_quantum_scout', title: 'Скин: Квант-скаут', subtitle: 'Разведчик будущего', icon: Icons.travel_explore_rounded, color: Color(0xFF3B82F6)),
    _DropItemDef(id: 'skin_vortex', title: 'Скин: Вортекс', subtitle: 'Энергетическая броня вихря', icon: Icons.cyclone_rounded, color: Color(0xFF0EA5E9)),
    _DropItemDef(id: 'skin_emerald_ace', title: 'Скин: Изумрудный ас', subtitle: 'Лаконичный топ-образ', icon: Icons.diamond_rounded, color: Color(0xFF16A34A)),
    _DropItemDef(id: 'skin_ruby_flash', title: 'Скин: Рубиновый флэш', subtitle: 'Красный динамичный стиль', icon: Icons.whatshot_rounded, color: Color(0xFFEF4444)),
  ];

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _unlockedSkins = (_prefs?.getStringList(_keyUnlockedSkins) ?? <String>[]).toSet();
    _unlockedBackgrounds =
        (_prefs?.getStringList(_keyUnlockedBackgrounds) ?? <String>[]).toSet();
    _history
      ..clear()
      ..addAll(_readHistory());
  }

  static List<DropReward> _readHistory() {
    final raw = _prefs?.getString(_keyHistory);
    if (raw == null || raw.isEmpty) return const <DropReward>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => DropReward.fromMap(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const <DropReward>[];
    }
  }

  static List<DropReward> getHistory({int limit = 12}) {
    final max = limit.clamp(1, 50);
    return _history.take(max).toList(growable: false);
  }

  static int getOwnedSkinCount() => _unlockedSkins.length;
  static int getOwnedBackgroundCount() => _unlockedBackgrounds.length;

  static List<DropSkinItem> getUnlockedSkinItems() {
    final items = _skinPool
        .where((s) => _unlockedSkins.contains(s.id))
        .map(
          (s) => DropSkinItem(
            id: s.id,
            title: s.title,
            subtitle: s.subtitle,
            icon: s.icon,
            color: s.color,
          ),
        )
        .toList(growable: false);
    return items;
  }

  static Future<DropReward> rollRandomDrop() async {
    final roll = _random.nextInt(100);
    if (roll < 45) {
      final amount = <int>[20, 30, 40, 50, 75, 100][_random.nextInt(6)];
      await ProgressService.addCoins(amount);
      final reward = DropReward(
        kind: DropKind.coins,
        id: 'coins_$amount',
        title: '+$amount монет',
        subtitle: 'Валюта для будущего магазина',
        icon: Icons.monetization_on_rounded,
        color: const Color(0xFFF59E0B),
        coins: amount,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      await _storeReward(reward);
      return reward;
    }

    if (roll < 82) {
      final notOwned = _skinPool.where((s) => !_unlockedSkins.contains(s.id)).toList();
      final item = notOwned.isNotEmpty ? notOwned[_random.nextInt(notOwned.length)] : _skinPool[_random.nextInt(_skinPool.length)];
      _unlockedSkins.add(item.id);
      await _prefs?.setStringList(_keyUnlockedSkins, _unlockedSkins.toList());
      final reward = DropReward(
        kind: DropKind.skin,
        id: item.id,
        title: item.title,
        subtitle: item.subtitle,
        icon: item.icon,
        color: item.color,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      await _storeReward(reward);
      return reward;
    }

    final notOwned = _backgroundPool.where((b) => !_unlockedBackgrounds.contains(b.id)).toList();
    final item = notOwned.isNotEmpty ? notOwned[_random.nextInt(notOwned.length)] : _backgroundPool[_random.nextInt(_backgroundPool.length)];
    _unlockedBackgrounds.add(item.id);
    await _prefs?.setStringList(_keyUnlockedBackgrounds, _unlockedBackgrounds.toList());
    final reward = DropReward(
      kind: DropKind.profileBackground,
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _storeReward(reward);
    return reward;
  }

  static Future<void> _storeReward(DropReward reward) async {
    _history.insert(0, reward);
    if (_history.length > 30) {
      _history.removeRange(30, _history.length);
    }
    final encoded = jsonEncode(_history.map((e) => e.toMap()).toList(growable: false));
    await _prefs?.setString(_keyHistory, encoded);
  }
}

