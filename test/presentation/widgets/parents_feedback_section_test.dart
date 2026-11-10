import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/feedback/feedback_email.dart';
import 'package:toddler_logic/presentation/widgets/parents_feedback_section.dart';

import '../l10n_test_support.dart';

class _FakeChannel implements IFeedbackChannel {
  _FakeChannel({required this.opens});

  final bool opens;
  final List<Uri> opened = [];
  String? language;

  @override
  Future<DeviceReport> readReport({required String language}) async {
    this.language = language;
    return DeviceReport(appVersion: '1.0.0+3', androidVersion: '14 (SDK 34)', model: 'moto g55', language: language);
  }

  @override
  Future<bool> openEmail(Uri email) async {
    opened.add(email);
    return opens;
  }
}

/// HU-032: la tarjeta «Ayuda y comentarios».
void main() {
  Future<void> pump(WidgetTester tester, {IFeedbackChannel? channel, Locale locale = testLocale}) async {
    const Widget section = Scaffold(body: SingleChildScrollView(child: ParentsFeedbackSection()));
    await tester.pumpWidget(localizedApp(
      locale: locale,
      home: channel == null ? section : RepositoryProvider<IFeedbackChannel>.value(value: channel, child: section),
    ));
  }

  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey<String>('parents-zone-feedback-send')));
    await tester.pumpAndSettle();
  }

  testWidgets('opens the email app with the prepared email in the app language (criterion 2)', (tester) async {
    final channel = _FakeChannel(opens: true);
    await pump(tester, channel: channel);
    expect(find.text('Ayuda y comentarios'), findsOneWidget);

    await send(tester);

    expect(channel.language, 'es');
    final Uri email = channel.opened.single;
    expect(email.path, FeedbackEmail.address);
    expect(email.queryParameters['subject'], 'ToddlerLogic · Comentarios (1.0.0+3)');
    expect(email.queryParameters['body'], startsWith('¿Qué pasó?'));
    expect(email.queryParameters['body'], endsWith('Language: es'));
    expect(find.byKey(const ValueKey<String>('parents-zone-feedback-address')), findsNothing);
  });

  testWidgets('without an email app, shows the address and copies it (criterion 3)', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pump(tester, channel: _FakeChannel(opens: false));

    await send(tester);
    expect(find.text('No pudimos abrir una app de correo. Escríbenos a:'), findsOneWidget);
    expect(find.text(FeedbackEmail.address), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('parents-zone-feedback-copy')));
    await tester.pump();
    expect(copied, [FeedbackEmail.address]);
    expect(find.text('Dirección copiada'), findsOneWidget);
  });

  testWidgets('without the channel (tests, other platforms) it falls back to the address', (tester) async {
    await pump(tester);
    await send(tester);
    expect(find.byKey(const ValueKey<String>('parents-zone-feedback-address')), findsOneWidget);
  });

  testWidgets('reads well in Arabic', (tester) async {
    await pump(tester, channel: _FakeChannel(opens: false), locale: const Locale('ar'));
    await send(tester);
    expect(find.text('المساعدة والملاحظات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
