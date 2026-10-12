import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/theme/accent_palette.dart';
import 'package:math_pilot/theme/theme_provider.dart';
import 'package:math_pilot/theme/app_theme.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/widgets/accent_color_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Accent persists, restores through backup, and validates hex', () async {
    SharedPreferences.setMockInitialValues({});
    final theme = ThemeProvider();
    await theme.reload();
    expect(theme.accentColor, AccentPalette.defaultColor);
    final custom = AccentPalette.parseHex('#B234E8')!;
    await theme.setAccentColor(custom);
    final next = ThemeProvider();
    await next.reload();
    expect(next.accentColor, custom);
    expect(AccentPalette.parseHex('invalid'), isNull);
    expect(AccentPalette.parseHex('#fff'), isNull);
    expect(AccentPalette.hex(custom), '#B234E8');
    await ProgressService.init();
    final backup = await BackupService.export();
    expect(BackupService.validate(backup)['accent_color'], custom.toARGB32());
    await next.setAccentColor(AccentPalette.defaultColor);
    await BackupService.restore(backup);
    await next.reload();
    expect(next.accentColor, custom);
    theme.dispose();
    next.dispose();
  });
  test('Every accent remains readable in both themes', () {
    for (final seed in [
      ...AccentPalette.presets.values,
      Colors.black,
      Colors.white,
      Colors.yellow,
      Colors.cyan,
    ]) {
      for (final brightness in Brightness.values) {
        final theme = brightness == Brightness.light
            ? buildLightTheme(accentColor: seed)
            : buildDarkTheme(accentColor: seed);
        final luminance = theme.colorScheme.primary.computeLuminance();
        expect(
          1.05 / (luminance + 0.05),
          greaterThanOrEqualTo(4.5),
          reason: '$seed $brightness white button label',
        );
        if (brightness == Brightness.dark) {
          expect(
            (luminance + 0.05) /
                (theme.colorScheme.surface.computeLuminance() + 0.05),
            greaterThanOrEqualTo(2.8),
          );
        }
        expect(
          theme.elevatedButtonTheme.style!.backgroundColor!.resolve({}),
          theme.colorScheme.primary,
        );
      }
    }
  });
  testWidgets('Palette and custom dialog apply live and fit narrow screens', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_language': 'ru'});
    final theme = ThemeProvider();
    await theme.reload();
    await LanguageService.instance.init();
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: theme),
          ChangeNotifierProvider.value(value: LanguageService.instance),
        ],
        child: Consumer<ThemeProvider>(
          builder: (_, theme, _) => MaterialApp(
            theme: buildLightTheme(accentColor: theme.accentColor),
            home: const Scaffold(
              body: SingleChildScrollView(child: AccentColorSettings()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('accent_Зелёный')));
    await tester.pumpAndSettle();
    expect(theme.accentColor, AccentPalette.presets['Зелёный']);
    await tester.tap(find.text('Свой цвет'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom_accent_hex')),
      '#nope',
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Применить'))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const ValueKey('custom_accent_hex')),
      '#AD3366',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(theme.accentColor, const Color(0xFFAD3366));
    await tester.tap(find.text('Сбросить'));
    await tester.pumpAndSettle();
    expect(theme.accentColor, AccentPalette.defaultColor);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    theme.dispose();
  });
}
