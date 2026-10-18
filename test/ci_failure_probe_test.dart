import 'package:flutter_test/flutter_test.dart';

// TEMPORAL (TD-001, criterio 2): comprueba que el CI falla con un test en rojo.
// Se revierte en el siguiente commit.
void main() {
  test('CI failure probe', () {
    expect(1 + 1, 3);
  });
}
