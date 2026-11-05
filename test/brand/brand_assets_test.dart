import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';

/// Identidad visual (HU-013): las imágenes existen, el icono de Android es
/// adaptativo con monocromo, su fondo es de la paleta y el icono de la tienda
/// cumple lo que pide Google Play.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String res = 'android/app/src/main/res';
  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  Future<ui.Image> decode(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  test('every brand image is bundled with the app', () async {
    for (final asset in BrandAssets.all) {
      final ByteData data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(0), reason: asset);
    }
  });

  test('the launcher icon is adaptive, with a monochrome layer for themed icons (criteria 1 and 2)', () {
    final String xml = File('$res/mipmap-anydpi-v26/ic_launcher.xml').readAsStringSync();
    expect(xml, contains('<adaptive-icon'));
    expect(xml, contains('@drawable/ic_launcher_foreground'));
    expect(xml, contains('@drawable/ic_launcher_monochrome'));
    for (final density in densities) {
      for (final file in [
        '$res/mipmap-$density/ic_launcher.png',
        '$res/drawable-$density/ic_launcher_foreground.png',
        '$res/drawable-$density/ic_launcher_monochrome.png',
      ]) {
        expect(File(file).existsSync(), isTrue, reason: file);
      }
    }
    expect(File('android/app/src/main/AndroidManifest.xml').readAsStringSync(), contains('@mipmap/ic_launcher'));
  });

  test('the launcher background is the deep teal of the palette (D-032)', () {
    final String colors = File('$res/values/colors.xml').readAsStringSync();
    final String hex = RegExp(r'ic_launcher_background">#([0-9A-Fa-f]{6})').firstMatch(colors)!.group(1)!;
    expect(int.parse('FF$hex', radix: 16), AppPalette.deepTeal.toARGB32());
  });

  test('the store icon is a 512 x 512 PNG without transparency (criterion 6)', () async {
    final ui.Image image = await decode(File('docs/store/icon-512.png').readAsBytesSync());
    expect([image.width, image.height], [512, 512]);
    final ByteData pixels = (await image.toByteData())!;
    var transparent = 0;
    for (var i = 3; i < pixels.lengthInBytes; i += 4) {
      if (pixels.getUint8(i) != 255) transparent++;
    }
    expect(transparent, 0);
  });
}
