import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_pilot/services/backup_service.dart';
import 'package:math_pilot/services/language_service.dart';
import 'package:math_pilot/services/progress_service.dart';
import 'package:math_pilot/widgets/progress_backup_dialog.dart';

void main() {
  testWidgets('Backup dialog validates and asks before replacing progress', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'user_name': 'Original'});
    await ProgressService.init();
    await LanguageService.instance.init();
    final backup = await BackupService.export();
    await ProgressService.setUserName('Current');
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const ProgressBackupDialog(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вставить копию'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), backup);
    FocusManager.instance.primaryFocus?.unfocus();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final review = find.text('Проверить и восстановить');
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();
    expect(find.text('Восстановить прогресс?'), findsOneWidget);
    expect(ProgressService.getUserName(), 'Current');
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(ProgressService.getUserName(), 'Current');
    await tester.ensureVisible(review);
    await tester.pumpAndSettle();
    await tester.tap(review);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить'));
    await tester.pumpAndSettle();
    expect(ProgressService.getUserName(), 'Original');
    expect(find.byType(ProgressBackupDialog), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
