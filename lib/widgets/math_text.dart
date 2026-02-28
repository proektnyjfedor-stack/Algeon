/// MathText — рендеринг текста с LaTeX-формулами.
///
/// Формулы обозначаются $...$, остальное — обычный текст.
/// Пример: 'Вычислите: $27^{\frac{2}{3}}$'

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final eff  = style != null ? base.merge(style) : base;

    final parts = _parse(text);

    // Только одна математическая формула — рендерим напрямую
    if (parts.length == 1) {
      final p = parts.first;
      if (p.isMath) {
        return Math.tex(
          p.content,
          textStyle: eff,
          mathStyle: MathStyle.text,
          onErrorFallback: (_) => Text(p.content, style: eff),
        );
      }
      return Text(p.content, style: eff, textAlign: textAlign);
    }

    // Смешанный контент — Wrap для inline-вёрстки
    return Wrap(
      alignment: textAlign == TextAlign.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((p) {
        if (p.isMath) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Math.tex(
              p.content,
              textStyle: eff,
              mathStyle: MathStyle.text,
              onErrorFallback: (_) => Text(p.content, style: eff),
            ),
          );
        }
        return Text(p.content, style: eff);
      }).toList(),
    );
  }

  List<_Part> _parse(String src) {
    final out   = <_Part>[];
    final regex = RegExp(r'\$([^$]+)\$');
    int last = 0;
    for (final m in regex.allMatches(src)) {
      if (m.start > last) out.add(_Part(src.substring(last, m.start), false));
      out.add(_Part(m.group(1)!, true));
      last = m.end;
    }
    if (last < src.length) out.add(_Part(src.substring(last), false));
    if (out.isEmpty) out.add(_Part(src, false));
    return out;
  }
}

class _Part {
  final String content;
  final bool isMath;
  const _Part(this.content, this.isMath);
}
