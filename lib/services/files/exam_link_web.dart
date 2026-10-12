import 'package:web/web.dart' as web;

void openExamLink(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
