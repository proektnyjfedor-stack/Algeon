import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:math_pilot/widgets/avatar_builder.dart';
import 'package:math_pilot/widgets/avatars.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'design_layout_test.dart' show loadDesignFonts;

class _AvatarFailStore extends InMemorySharedPreferencesStore {
  _AvatarFailStore() : super.empty();
  bool failActivation = false;
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (failActivation && key.endsWith('user_avatar')) {
      failActivation = false;
      return false;
    }
    return super.setValue(type, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Legacy avatars preserve their appearance and new fields round trip',
    () {
      final legacy = defaultCustomAvatar.toMap()
        ..remove('eyeColor')
        ..remove('accessoryColor')
        ..remove('outfit');
      expect(AvatarData.fromMap(legacy), defaultCustomAvatar);
      final upgraded = defaultCustomAvatar.copyWith(
        eyeColor: Colors.green,
        accessoryColor: Colors.purple,
        outfit: 'striped',
      );
      expect(AvatarData.fromJson(upgraded.toJson()), upgraded);
      expect(
        upgraded.hashCode,
        AvatarData.fromJson(upgraded.toJson()).hashCode,
      );
      expect(
        AvatarData.fromMap({
          'skinColor': 'bad',
          'hairStyle': [],
          'outfit': 'missing',
        }).hairStyle,
        'boy_short',
      );
    },
  );
  test('New character survives backup and preference reload', () async {
    SharedPreferences.setMockInitialValues({});
    await ProgressService.init();
    final avatar = defaultCustomAvatar.copyWith(
      eyeColor: Colors.blue,
      outfit: 'hoodie',
      accessory: 'glasses',
      accessoryColor: Colors.red,
    );
    await ProgressService.setCustomAvatar(avatar.toMap());
    final backup = await BackupService.export();
    BackupService.validate(backup);
    await ProgressService.init();
    expect(ProgressService.getAvatar(), 'custom');
    expect(AvatarData.fromMap(ProgressService.getCustomAvatar()!), avatar);
  });

  test('Failed activation restores the previous avatar and mode', () async {
    final originalStore = SharedPreferencesStorePlatform.instance;
    final store = _AvatarFailStore();
    SharedPreferencesStorePlatform.instance = store;
    SharedPreferences.resetStatic();
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = originalStore;
      SharedPreferences.resetStatic();
    });
    await ProgressService.init();
    await ProgressService.setCustomAvatar(defaultCustomAvatar.toMap());
    await ProgressService.setAvatar('boy_green');
    store.failActivation = true;
    await expectLater(
      ProgressService.setCustomAvatar(
        defaultCustomAvatar.copyWith(outfit: 'hoodie').toMap(),
      ),
      throwsStateError,
    );
    expect(ProgressService.getAvatar(), 'boy_green');
    expect(
      AvatarData.fromMap(ProgressService.getCustomAvatar()!),
      defaultCustomAvatar,
    );
  });

  Future<void> open(
    WidgetTester tester,
    FutureOr<void> Function(AvatarData) save, {
    GlobalKey? boundary,
    bool dark = false,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Inter',
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  constraints: const BoxConstraints(maxWidth: 1000),
                  builder: (_) => AvatarBuilderSheet(
                    initialAvatar: defaultCustomAvatar,
                    onSave: save,
                  ),
                ),
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
  }

  testWidgets('HEX editing, undo and awaited save preserve changes', (
    tester,
  ) async {
    AvatarData? saved;
    final gate = Completer<void>();
    await open(tester, (avatar) async {
      saved = avatar;
      await gate.future;
    });
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Фон'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Фон'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Свой цвет: Цвет фона'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('avatar_hex')), 'nope');
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Нужно 6 символов'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('avatar_hex')), '123ABC');
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Отменить изменение'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('avatar_save')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(saved!.bgColor, defaultCustomAvatar.bgColor);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('avatar_save')))
          .onPressed,
      isNull,
    );
    expect(find.byType(AvatarBuilderSheet), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AvatarBuilderSheet), findsNothing);
  });
  testWidgets('Failed save stays open and dirty exit needs confirmation', (
    tester,
  ) async {
    await open(tester, (_) => Future<void>.error(StateError('test')));
    await tester.tap(find.byTooltip('Случайный образ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('avatar_save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Не удалось сохранить'), findsOneWidget);
    await tester.tap(find.byTooltip('Закрыть редактор'));
    await tester.pumpAndSettle();
    expect(find.text('Выйти без сохранения?'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarBuilderSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Закрыть редактор'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarBuilderSheet), findsNothing);
  });
  testWidgets('Studio fits phone, landscape and desktop with every category', (
    tester,
  ) async {
    await tester.runAsync(loadDesignFonts);
    for (final size in [
      const Size(320, 740),
      const Size(740, 360),
      const Size(1100, 850),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final boundary = GlobalKey();
      await open(tester, (_) {}, boundary: boundary);
      for (final category in [
        'Волосы',
        'Лицо',
        'Одежда',
        'Аксессуары',
        'Фон',
      ]) {
        final chip = find.widgetWithText(ChoiceChip, category);
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size $category');
        if (category == 'Одежда') {
          await tester.tap(find.byKey(const ValueKey('avatar_option_hoodie')));
          await tester.pumpAndSettle();
          if (Platform.environment['ALGEON_CAPTURE_AVATAR'] == '1') {
            await tester.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await File(
                '/tmp/algeon-avatar-${size.width.toInt()}.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  testWidgets('Dark studio supports enlarged text on a narrow phone', (
    tester,
  ) async {
    await tester.runAsync(loadDesignFonts);
    tester.view.physicalSize = const Size(320, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await open(tester, (_) {}, boundary: boundary, dark: true, textScale: 1.25);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Лицо'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Лицо'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (Platform.environment['ALGEON_CAPTURE_AVATAR'] == '1') {
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '/tmp/algeon-avatar-dark.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
