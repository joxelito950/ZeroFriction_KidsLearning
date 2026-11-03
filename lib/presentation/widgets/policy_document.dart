import 'package:flutter/material.dart';

/// Tipos de bloque del Markdown mínimo de `docs/privacy/` (HU-014): títulos,
/// párrafos y viñetas, con **negrita** y *cursiva* dentro del texto.
enum PolicyBlockKind { title, heading, paragraph, bullet }

final class PolicyBlock {
  const PolicyBlock(this.kind, this.text);

  final PolicyBlockKind kind;
  final String text;

  @override
  bool operator ==(Object other) => other is PolicyBlock && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);
}

/// Divide el Markdown en bloques. Las líneas seguidas forman un mismo párrafo.
List<PolicyBlock> parsePolicy(String markdown) {
  final blocks = <PolicyBlock>[];
  final paragraph = <String>[];

  void closeParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(PolicyBlock(PolicyBlockKind.paragraph, paragraph.join(' ')));
    paragraph.clear();
  }

  for (final String raw in markdown.split('\n')) {
    final String line = raw.trimRight();
    if (line.trim().isEmpty) {
      closeParagraph();
    } else if (line.startsWith('## ')) {
      closeParagraph();
      blocks.add(PolicyBlock(PolicyBlockKind.heading, line.substring(3).trim()));
    } else if (line.startsWith('# ')) {
      closeParagraph();
      blocks.add(PolicyBlock(PolicyBlockKind.title, line.substring(2).trim()));
    } else if (line.startsWith('- ')) {
      closeParagraph();
      blocks.add(PolicyBlock(PolicyBlockKind.bullet, line.substring(2).trim()));
    } else {
      paragraph.add(line.trim());
    }
  }
  closeParagraph();
  return blocks;
}

final RegExp _emphasis = RegExp(r'\*\*([^*]+)\*\*|\*([^*]+)\*');

/// El texto con su negrita y su cursiva.
List<InlineSpan> policySpans(String text) {
  final spans = <InlineSpan>[];
  var start = 0;
  for (final match in _emphasis.allMatches(text)) {
    if (match.start > start) spans.add(TextSpan(text: text.substring(start, match.start)));
    spans.add(
      match.group(1) != null
          ? TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold))
          : TextSpan(text: match.group(2), style: const TextStyle(fontStyle: FontStyle.italic)),
    );
    start = match.end;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return spans;
}

/// Pinta la política de privacidad con el tema de la app.
class PolicyDocument extends StatelessWidget {
  const PolicyDocument({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in parsePolicy(markdown))
          switch (block.kind) {
            PolicyBlockKind.title => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  header: true,
                  child: Text.rich(TextSpan(children: policySpans(block.text)), style: text.headlineSmall),
                ),
              ),
            PolicyBlockKind.heading => Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Semantics(
                  header: true,
                  child: Text.rich(
                    TextSpan(children: policySpans(block.text)),
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            PolicyBlockKind.paragraph => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text.rich(TextSpan(children: policySpans(block.text)), style: text.bodyMedium),
              ),
            PolicyBlockKind.bullet => Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', style: text.bodyMedium),
                    const SizedBox(width: 8),
                    Expanded(child: Text.rich(TextSpan(children: policySpans(block.text)), style: text.bodyMedium)),
                  ],
                ),
              ),
          },
      ],
    );
  }
}
