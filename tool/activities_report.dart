// Estado del contenido de «Actividades sin pantallas» (HU-047): cuántas hay
// por categoría y por tiempo, cuánto falta para la meta de 1000 y cuánto está
// traducido cada idioma. Las reglas las vigila
// test/data/activities/activity_assets_test.dart; esto solo informa.
//
// Uso: dart run tool/activities_report.dart
import 'dart:convert';
import 'dart:io';

const int goal = 1000;
const List<String> languages = ['es', 'en', 'fr', 'it', 'de', 'pt', 'ja', 'ko', 'ar'];

void main() {
  final Directory folder = Directory('assets/activities');
  Map<String, dynamic>? read(String name) {
    final File file = File('${folder.path}/$name.json');
    return file.existsSync() ? jsonDecode(file.readAsStringSync()) as Map<String, dynamic> : null;
  }

  final List<Map<String, dynamic>> entries = [
    for (final Object? entry in read('catalog')!['activities'] as List) (entry as Map).cast<String, dynamic>(),
  ];
  final int total = entries.length;
  stdout.writeln('Actividades: $total de $goal (${(100 * total / goal).toStringAsFixed(1)} %)');

  final Map<String, int> byCategory = {};
  final Map<String, int> byTime = {};
  final Map<int, int> byAge = {};
  for (final Map<String, dynamic> entry in entries) {
    byCategory.update(entry['category'] as String, (n) => n + 1, ifAbsent: () => 1);
    final int minutes = entry['minutes'] as int;
    final String time = minutes <= 5
        ? '≤5'
        : minutes <= 10
            ? '≤10'
            : minutes <= 15
                ? '≤15'
                : minutes <= 30
                    ? '≤30'
                    : '>30';
    byTime.update(time, (n) => n + 1, ifAbsent: () => 1);
    byAge.update(entry['ageFrom'] as int, (n) => n + 1, ifAbsent: () => 1);
  }
  stdout.writeln('Por categoría: ${byCategory.entries.map((e) => '${e.key} ${e.value}').join(' · ')}');
  stdout.writeln('Por tiempo (min): ${byTime.entries.map((e) => '${e.key} ${e.value}').join(' · ')}');
  stdout.writeln('Por edad mínima: ${(byAge.keys.toList()..sort()).map((a) => '$a años ${byAge[a]}').join(' · ')}');
  final int handPicked = entries.where((e) => ((e['recommended'] as List?) ?? const []).isNotEmpty).length;
  stdout.writeln('Con recomendadas elegidas a mano: $handPicked (el resto, automáticas)');

  stdout.writeln('Traducción:');
  final Set<String> ids = {for (final Map<String, dynamic> entry in entries) entry['id'] as String};
  for (final String language in languages) {
    final Map<String, dynamic>? texts = read(language);
    final int done = texts == null ? 0 : ((texts['activities'] as Map).keys.where(ids.contains).length);
    final String bar = '#' * (20 * done ~/ (total == 0 ? 1 : total));
    stdout.writeln(
        '  $language ${'$done'.padLeft(4)}/$total ${bar.padRight(20, '.')}${texts == null ? '  (sin archivo: sale en inglés)' : ''}');
  }
}
