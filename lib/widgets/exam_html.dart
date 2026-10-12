import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'math_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class ExamHtml extends StatelessWidget {
  const ExamHtml(this.html, {super.key});
  final String html;
  static String formatNotation(String source) {
    final fragment = parser.parseFragment(source);
    void visit(dom.Node node) {
      for (final child in node.nodes.toList()) {
        if (child is dom.Text) {
          final parts = MathNotation.parts(child.text);
          if (!parts.any((p) => p.math)) continue;
          final replacement = dom.Element.tag('span');
          for (final part in parts) {
            if (part.math) {
              replacement.append(
                dom.Element.tag('span')
                  ..attributes['data-algeon-math'] = part.content,
              );
            } else {
              replacement.append(dom.Text(part.content));
            }
          }
          child.replaceWith(replacement);
        } else {
          visit(child);
        }
      }
    }

    visit(fragment);
    return fragment.outerHtml;
  }

  @override
  Widget build(BuildContext context) => HtmlWidget(
    formatNotation(html),
    textStyle: const TextStyle(fontSize: 17, height: 1.6),
    customWidgetBuilder: (element) {
      final formulaText = element.attributes['data-algeon-math'];
      if (formulaText != null) {
        return InlineCustomWidget(
          child: MathText(
            '\$$formulaText\$',
            style: const TextStyle(fontSize: 18),
          ),
        );
      }
      if (element.localName != 'img') return null;
      final path = (element.attributes['src'] ?? '').replaceFirst(
        'asset://',
        '',
      );
      if (!path.startsWith('assets/exams/images/')) {
        return const SizedBox.shrink();
      }
      final formula = element.classes.contains('tex');
      final width = double.tryParse(element.attributes['width'] ?? '');
      final height = double.tryParse(element.attributes['height'] ?? '');
      Widget graphic() => path.endsWith('.svg')
          ? SvgPicture.asset(
              path,
              width: formula ? width : null,
              height: formula ? height : null,
              semanticsLabel: element.attributes['alt'],
              colorFilter: formula
                  ? ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    )
                  : null,
            )
          : Image.asset(path, semanticLabel: element.attributes['alt']);
      if (formula) {
        final available = (MediaQuery.sizeOf(context).width - 72).clamp(
          120.0,
          800.0,
        );
        return InlineCustomWidget(
          child: width != null && width > available
              ? SizedBox(
                  width: available,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: graphic(),
                  ),
                )
              : graphic(),
        );
      }
      return GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: graphic(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 380),
            child: graphic(),
          ),
        ),
      );
    },
  );
}
