import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'avatars.dart';

const _hairLabels = {
  'boy_short': 'Короткие',
  'boy_spiky': 'Ёжик',
  'girl_long': 'Длинные',
  'girl_pigtails': 'Косички',
  'girl_short': 'Каре',
  'bald': 'Без волос',
  'curly': 'Кудри',
  'ponytail': 'Хвост',
  'mohawk': 'Ирокез',
  'afro': 'Афро',
};
const _accessoryLabels = {
  'none': 'Без аксессуара',
  'glasses': 'Очки',
  'bow': 'Бант',
  'hat': 'Шляпа',
  'headband': 'Ободок',
  'crown': 'Корона',
  'earrings': 'Серьги',
  'mask': 'Маска',
  'necklace': 'Подвеска',
};
const _expressionLabels = {
  'smile': 'Улыбка',
  'grin': 'Радость',
  'wink': 'Подмигивание',
  'surprised': 'Удивление',
  'cool': 'Солнечные очки',
};

class AvatarBuilderSheet extends StatefulWidget {
  const AvatarBuilderSheet({
    super.key,
    required this.initialAvatar,
    required this.onSave,
  });
  final AvatarData initialAvatar;
  final FutureOr<void> Function(AvatarData) onSave;
  @override
  State<AvatarBuilderSheet> createState() => _AvatarBuilderSheetState();
}

class _AvatarBuilderSheetState extends State<AvatarBuilderSheet> {
  late AvatarData _avatar;
  final _history = <AvatarData>[];
  int _category = 0;
  bool _saving = false;
  String? _error;
  static const _categories = [
    'Образ',
    'Волосы',
    'Лицо',
    'Одежда',
    'Аксессуары',
    'Фон',
  ];
  @override
  void initState() {
    super.initState();
    _avatar = widget.initialAvatar;
  }

  bool get _dirty => _avatar != widget.initialAvatar;

  void _change(AvatarData next) {
    if (_saving || next == _avatar) return;
    setState(() {
      _history.add(_avatar);
      if (_history.length > 50) _history.removeAt(0);
      _avatar = next;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_avatar);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'Не удалось сохранить. Попробуй ещё раз — твой образ остался здесь.';
        });
      }
    }
  }

  Future<void> _close() async {
    if (_saving) return;
    if (_dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Выйти без сохранения?'),
          content: const Text('Изменения внешности не сохранятся.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Продолжить'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Выйти'),
            ),
          ],
        ),
      );
      if (discard != true) return;
    }
    if (mounted) Navigator.pop(context);
  }

  void _randomize() {
    final random = Random();
    T pick<T>(List<T> items) => items[random.nextInt(items.length)];
    _change(
      _avatar.copyWith(
        id: 'custom',
        bgColor: pick(avatarBgColors),
        hairStyle: pick(avatarHairStyles),
        hairColor: pick(avatarHairColors),
        shirtColor: pick(avatarShirtColors),
        accessory: pick(avatarAccessories),
        expression: pick(avatarExpressions),
        outfit: pick(const ['tshirt', 'hoodie', 'striped']),
      ),
    );
  }

  Future<void> _customColor(
    String label,
    Color color,
    ValueChanged<Color> apply,
  ) async {
    final input = TextEditingController(
      text: color
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase(),
    );
    String? error;
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          void submit() {
            final value = input.text.trim().replaceFirst(RegExp(r'^#'), '');
            if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
              update(() => error = 'Нужно 6 символов: например, 7C3AED');
              return;
            }
            Navigator.pop(context, Color(int.parse('FF$value', radix: 16)));
          }

          return AlertDialog(
            title: Text(label),
            content: TextField(
              key: const ValueKey('avatar_hex'),
              controller: input,
              autofocus: true,
              maxLength: 7,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Цвет HEX',
                prefixText: '#',
                errorText: error,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(onPressed: submit, child: const Text('Применить')),
            ],
          );
        },
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    input.dispose();
    if (mounted && !_saving && result != null) apply(result);
  }

  Widget _colors(
    String title,
    List<Color> palette,
    Color selected,
    ValueChanged<Color> apply,
  ) {
    final colors = {...palette, selected}.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final color in colors)
              Semantics(
                label:
                    '$title #${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                selected: selected == color,
                button: true,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: color,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: selected == color
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withValues(alpha: .35),
                        width: selected == color ? 3 : 1,
                      ),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _saving ? null : () => apply(color),
                      child: selected == color
                          ? ExcludeSemantics(
                              child: Icon(
                                Icons.check,
                                color: color.computeLuminance() > .45
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton.filledTonal(
                tooltip: 'Свой цвет: $title',
                onPressed: _saving
                    ? null
                    : () => _customColor(title, selected, apply),
                icon: const Icon(Icons.colorize),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _choices(
    Map<String, String> options,
    String selected,
    AvatarData Function(String) variant, {
    bool preview = true,
  }) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: options.entries.map((entry) {
      final active = entry.key == selected;
      return Semantics(
        selected: active,
        child: OutlinedButton(
          key: ValueKey('avatar_option_${entry.key}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            backgroundColor: active
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            side: BorderSide(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: active ? 2 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _saving ? null : () => _change(variant(entry.key)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (preview) ...[
                ExcludeSemantics(
                  child: AvatarWidget(avatarData: variant(entry.key), size: 64),
                ),
                const SizedBox(height: 6),
              ],
              Text(entry.value),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _options() {
    switch (_category) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Начни с готового образа или измени детали в соседних вкладках.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final preset in allAvatars.where(
                  (a) => a.id != 'robot' && a.id != 'cat',
                ))
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => _change(
                            preset.copyWith(id: 'custom', name: _avatar.name),
                          ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Semantics(
                        label: 'Готовый образ ${preset.name}',
                        image: true,
                        child: AvatarWidget(avatarData: preset, size: 76),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _choices(
              _hairLabels,
              _avatar.hairStyle,
              (v) => _avatar.copyWith(hairStyle: v),
            ),
            const SizedBox(height: 24),
            _colors(
              'Цвет волос',
              avatarHairColors,
              _avatar.hairColor,
              (v) => _change(_avatar.copyWith(hairColor: v)),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _colors(
              'Тон кожи',
              avatarSkinColors,
              _avatar.skinColor,
              (v) => _change(_avatar.copyWith(skinColor: v)),
            ),
            _colors(
              'Цвет глаз',
              const [
                Color(0xFF2C1810),
                Color(0xFF2D6A4F),
                Color(0xFF2563EB),
                Color(0xFF64748B),
                Color(0xFF7C3AED),
              ],
              _avatar.eyeColor,
              (v) => _change(_avatar.copyWith(eyeColor: v)),
            ),
            _choices(
              _expressionLabels,
              _avatar.expression,
              (v) => _avatar.copyWith(expression: v),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _choices(
              const {
                'tshirt': 'Футболка',
                'hoodie': 'Худи',
                'striped': 'Полоски',
              },
              _avatar.outfit,
              (v) => _avatar.copyWith(outfit: v),
            ),
            const SizedBox(height: 24),
            _colors(
              'Цвет одежды',
              avatarShirtColors,
              _avatar.shirtColor,
              (v) => _change(_avatar.copyWith(shirtColor: v)),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _choices(
              _accessoryLabels,
              _avatar.accessory,
              (v) => _avatar.copyWith(accessory: v),
            ),
            const SizedBox(height: 24),
            if (_avatar.accessory != 'none')
              _colors(
                'Цвет аксессуара',
                [...avatarShirtColors, const Color(0xFFFFD700)],
                _avatar.effectiveAccessoryColor,
                (v) => _change(_avatar.copyWith(accessoryColor: v)),
              ),
          ],
        );
      default:
        return _colors(
          'Цвет фона',
          avatarBgColors,
          _avatar.bgColor,
          (v) => _change(_avatar.copyWith(bgColor: v)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compact = media.size.height < 620;
    final preview = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: Semantics(
            image: true,
            label: 'Предпросмотр персонажа',
            child: AvatarWidget(
              avatarData: _avatar,
              size: compact ? 100 : 156,
              showBorder: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Отменить изменение',
              onPressed: _saving || _history.isEmpty
                  ? null
                  : () => setState(() => _avatar = _history.removeLast()),
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Случайный образ',
              onPressed: _saving ? null : _randomize,
              icon: const Icon(Icons.shuffle),
            ),
            TextButton(
              onPressed: _saving || !_dirty
                  ? null
                  : () => _change(widget.initialAvatar),
              child: const Text('Сбросить'),
            ),
          ],
        ),
      ],
    );
    return PopScope(
      canPop: !_saving && !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) unawaited(_close());
      },
      child: Container(
        height: media.size.height * .92,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
                child: Row(
                  children: [
                    if (compact && media.size.width < 680) ...[
                      AvatarWidget(avatarData: _avatar, size: 44),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        'Мой персонаж',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть редактор',
                      onPressed: _saving ? null : _close,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 680;
                    final options = Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              for (var i = 0; i < _categories.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(_categories[i]),
                                    selected: i == _category,
                                    onSelected: _saving
                                        ? null
                                        : (_) => setState(() => _category = i),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            key: ValueKey(_category),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: _options(),
                            ),
                          ),
                        ),
                      ],
                    );
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 240, child: Center(child: preview)),
                          Expanded(child: options),
                        ],
                      );
                    }
                    if (compact) return options;
                    return Column(
                      children: [
                        preview,
                        const SizedBox(height: 12),
                        Expanded(child: options),
                      ],
                    );
                  },
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('avatar_save'),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_saving ? 'Сохраняем…' : 'Сохранить персонажа'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
