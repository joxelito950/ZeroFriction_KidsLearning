import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/policy_document.dart';

import '../l10n_test_support.dart';

void main() {
  group('parsePolicy', () {
    test('splits titles, headings, paragraphs and bullets', () {
      const markdown = '''
# Title

First line
of a paragraph.

## Heading
- One
- Two

Last paragraph.
''';

      expect(parsePolicy(markdown), const [
        PolicyBlock(PolicyBlockKind.title, 'Title'),
        PolicyBlock(PolicyBlockKind.paragraph, 'First line of a paragraph.'),
        PolicyBlock(PolicyBlockKind.heading, 'Heading'),
        PolicyBlock(PolicyBlockKind.bullet, 'One'),
        PolicyBlock(PolicyBlockKind.bullet, 'Two'),
        PolicyBlock(PolicyBlockKind.paragraph, 'Last paragraph.'),
      ]);
    });

    test('accepts Windows line endings', () {
      expect(parsePolicy('# Title\r\n\r\nText\r\n'), const [
        PolicyBlock(PolicyBlockKind.title, 'Title'),
        PolicyBlock(PolicyBlockKind.paragraph, 'Text'),
      ]);
    });
  });

  test('policySpans keeps bold and italic text', () {
    final List<InlineSpan> spans = policySpans('Plain **bold** and *italic*.');
    final List<TextSpan> texts = spans.cast<TextSpan>();

    expect(texts.map((span) => span.text), ['Plain ', 'bold', ' and ', 'italic', '.']);
    expect(texts[1].style?.fontWeight, FontWeight.bold);
    expect(texts[3].style?.fontStyle, FontStyle.italic);
  });

  testWidgets('PolicyDocument marks the title and headings for screen readers', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      localizedApp(home: const Scaffold(body: PolicyDocument(markdown: '# Title\n\n## Heading\n\n- Item\n\nText'))),
    );

    expect(tester.getSemantics(find.text('Title')), matchesSemantics(label: 'Title', isHeader: true));
    expect(tester.getSemantics(find.text('Heading')), matchesSemantics(label: 'Heading', isHeader: true));
    expect(find.text('•'), findsOneWidget);
    expect(find.text('Item'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
    semantics.dispose();
  });
}
