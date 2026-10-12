import 'package:flutter/services.dart';

void openExamLink(String url) {
  Clipboard.setData(ClipboardData(text: url));
}
