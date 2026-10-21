// Verifica los umbrales de cobertura definidos en SPECIFICATION.md (sección 6).
//
// Uso:
//   flutter test --coverage
//   dart run tool/coverage_check.dart [ruta/lcov.info] [--min-total=90] [--min-file=80]
import 'dart:io';

const List<String> _excludedSuffixes = ['.g.dart'];
const List<String> _excludedFiles = ['lib/main.dart'];
// Catálogo de textos generado por gen-l10n desde lib/l10n/*.arb (HU-011).
final RegExp _generatedLocalizations = RegExp(r'lib/l10n/app_localizations[\w]*\.dart$');

void main(List<String> args) {
  final double minTotal = _readThreshold(args, '--min-total=', 90);
  final double minFile = _readThreshold(args, '--min-file=', 80);
  final String lcovPath =
      args.firstWhere((arg) => !arg.startsWith('--'), orElse: () => 'coverage/lcov.info');

  final lcov = File(lcovPath);
  if (!lcov.existsSync()) {
    stderr.writeln('No existe $lcovPath. Ejecuta primero: flutter test --coverage');
    exit(2);
  }

  final Map<String, (int hit, int found)> coverageByFile = _parseLcov(lcov.readAsLinesSync());
  var totalHit = 0;
  var totalFound = 0;
  final failingFiles = <String>[];

  for (final MapEntry(key: path, value: (hit, found)) in coverageByFile.entries) {
    if (found == 0) continue;
    totalHit += hit;
    totalFound += found;
    final double percent = hit * 100 / found;
    final bool belowFloor = percent < minFile;
    if (belowFloor) failingFiles.add(path);
    stdout.writeln('${belowFloor ? '✗' : ' '} ${percent.toStringAsFixed(1).padLeft(5)}%  $hit/$found  $path');
  }

  final double totalPercent = totalFound == 0 ? 0 : totalHit * 100 / totalFound;
  stdout.writeln('\nTotal: ${totalPercent.toStringAsFixed(1)}% ($totalHit/$totalFound líneas) · '
      'mínimo total $minTotal% · mínimo por archivo $minFile%');

  if (totalPercent < minTotal || failingFiles.isNotEmpty) {
    stderr.writeln('Cobertura insuficiente.');
    exit(1);
  }
  stdout.writeln('Cobertura OK.');
}

double _readThreshold(List<String> args, String prefix, double fallback) {
  final String? arg = args.where((value) => value.startsWith(prefix)).firstOrNull;
  return arg == null ? fallback : double.parse(arg.substring(prefix.length));
}

Map<String, (int, int)> _parseLcov(List<String> lines) {
  final result = <String, (int, int)>{};
  String? currentFile;
  var hit = 0;
  var found = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll(r'\', '/');
      hit = 0;
      found = 0;
    } else if (line.startsWith('LH:')) {
      hit = int.parse(line.substring(3));
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && currentFile != null) {
      if (!_isExcluded(currentFile)) result[currentFile] = (hit, found);
      currentFile = null;
    }
  }
  return result;
}

bool _isExcluded(String path) =>
    _excludedSuffixes.any(path.endsWith) ||
    _excludedFiles.any(path.endsWith) ||
    _generatedLocalizations.hasMatch(path);
