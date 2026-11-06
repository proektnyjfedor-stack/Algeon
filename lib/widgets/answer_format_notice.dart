import 'package:flutter/material.dart';

/// A notation correction leaves the answer editable and does not record a mistake.
void showAnswerFormatNotice(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(label: 'Исправить', onPressed: () {}),
    ),
  );
}
