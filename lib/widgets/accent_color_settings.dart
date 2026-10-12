import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/accent_palette.dart';
import '../services/language_service.dart';

class AccentColorSettings extends StatelessWidget {
  const AccentColorSettings({super.key});
  Future<void> _save(BuildContext context, Color color) async {
    try {
      await context.read<ThemeProvider>().setAccentColor(color);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить цвет. Попробуйте ещё раз.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final english = context.watch<LanguageService>().isEnglish;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            english ? 'Accent color' : 'Акцентный цвет',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            english
                ? 'Buttons, navigation and highlights'
                : 'Цвет кнопок и выделений',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AccentPalette.presets.entries.map((entry) {
              final selected =
                  theme.accentColor.toARGB32() == entry.value.toARGB32();
              final names = {
                'Синий': 'Blue',
                'Зелёный': 'Green',
                'Бирюзовый': 'Teal',
                'Фиолетовый': 'Purple',
                'Розовый': 'Pink',
                'Оранжевый': 'Orange',
                'Графит': 'Graphite',
              };
              return Semantics(
                selected: selected,
                button: true,
                label: english ? names[entry.key] : entry.key,
                child: Tooltip(
                  message: english ? names[entry.key]! : entry.key,
                  child: InkWell(
                    key: ValueKey('accent_${entry.key}'),
                    onTap: () => _save(context, entry.value),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: entry.value,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDialog<Color>(
                    context: context,
                    builder: (_) => _CustomAccentDialog(
                      initial: theme.accentColor,
                      english: english,
                    ),
                  );
                  if (selected != null && context.mounted) {
                    await _save(context, selected);
                  }
                },
                icon: const Icon(Icons.palette_outlined),
                label: Text(english ? 'Custom color' : 'Свой цвет'),
              ),
              if (theme.accentColor != AccentPalette.defaultColor)
                TextButton(
                  onPressed: () => _save(context, AccentPalette.defaultColor),
                  child: Text(english ? 'Reset' : 'Сбросить'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomAccentDialog extends StatefulWidget {
  const _CustomAccentDialog({required this.initial, required this.english});
  final Color initial;
  final bool english;
  @override
  State<_CustomAccentDialog> createState() => _CustomAccentDialogState();
}

class _CustomAccentDialogState extends State<_CustomAccentDialog> {
  late Color color = widget.initial;
  late final controller = TextEditingController(text: AccentPalette.hex(color));
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void channel(int index, double value) {
    final channels = [
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    ];
    channels[index] = value.round();
    setState(() {
      color = Color.fromARGB(255, channels[0], channels[1], channels[2]);
      controller.text = AccentPalette.hex(color);
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final english = widget.english;
    final primary = AccentPalette.primary(color, Theme.of(context).brightness);
    return AlertDialog(
      title: Text(english ? 'Custom accent color' : 'Свой акцентный цвет'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  english ? 'Button preview' : 'Так будут выглядеть кнопки',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const ValueKey('custom_accent_hex'),
                controller: controller,
                maxLength: 7,
                decoration: InputDecoration(
                  labelText: 'HEX',
                  hintText: '#7C3AED',
                  errorText: error,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final parsed = AccentPalette.parseHex(value);
                  setState(() {
                    if (parsed != null) color = parsed;
                    error = parsed == null
                        ? (english
                              ? 'Use 6 hexadecimal digits'
                              : 'Введите 6 символов: 0–9 и A–F')
                        : null;
                  });
                },
              ),
              for (var i = 0; i < 3; i++)
                Row(
                  children: [
                    Text(['R', 'G', 'B'][i]),
                    Expanded(
                      child: Slider(
                        value: [color.r, color.g, color.b][i] * 255,
                        min: 0,
                        max: 255,
                        divisions: 255,
                        label: ([color.r, color.g, color.b][i] * 255)
                            .round()
                            .toString(),
                        onChanged: (value) => channel(i, value),
                      ),
                    ),
                  ],
                ),
              Text(
                english
                    ? 'The shade adapts to keep text readable.'
                    : 'Оттенок адаптируется, чтобы текст оставался читаемым.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(english ? 'Cancel' : 'Отмена'),
        ),
        FilledButton(
          onPressed: AccentPalette.parseHex(controller.text) == null
              ? null
              : () => Navigator.pop(context, color),
          child: Text(english ? 'Apply' : 'Применить'),
        ),
      ],
    );
  }
}
