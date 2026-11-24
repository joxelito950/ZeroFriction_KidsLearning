import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/activities/activity.dart';

/// Las actividades sin pantallas (HU-047) desde los assets: la estructura en
/// `assets/activities/catalog.json` y los textos en `<idioma>.json`. Todo va
/// dentro de la app, sin red (R5, D-033).
class AssetActivitySource implements IActivitySource {
  AssetActivitySource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String folder = 'assets/activities';

  /// Si un idioma aún no tiene textos, o le falta alguna actividad, se usa el
  /// inglés.
  static const String fallbackLanguage = 'en';

  final AssetBundle _bundle;
  final Map<String, ActivityLibrary> _cache = {};

  @override
  Future<ActivityLibrary> load(String languageCode) async {
    if (_cache[languageCode] case final ActivityLibrary cached) return cached;
    final Map<String, dynamic> catalog = await _json('catalog');
    final Map<String, dynamic> fallback = await _json(fallbackLanguage);
    Map<String, dynamic> texts;
    try {
      texts = languageCode == fallbackLanguage ? fallback : await _json(languageCode);
    } on FlutterError {
      texts = fallback;
    }
    // Lo que aún no está traducido sale en inglés, actividad por actividad.
    return _cache[languageCode] = ActivityLibrary.fromJson(catalog, texts, fallback: fallback);
  }

  Future<Map<String, dynamic>> _json(String name) async =>
      jsonDecode(await _bundle.loadString('$folder/$name.json', cache: false)) as Map<String, dynamic>;
}
