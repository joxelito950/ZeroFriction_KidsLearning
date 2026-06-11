import 'package:meta/meta.dart';

/// Modelo inmutable que representa una carta individual en el tablero de juego.
@immutable
class MemoryCard {
  final int id;
  final String assetPath;
  final bool isFaceUp;
  final bool isMatched;

  const MemoryCard({
    required this.id,
    required this.assetPath,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  /// Crea una copia de este objeto modificando únicamente los campos provistos.
  MemoryCard copyWith({
    int? id,
    String? assetPath,
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          assetPath == other.assetPath &&
          isFaceUp == other.isFaceUp &&
          isMatched == other.isMatched;

  @override
  int get hashCode =>
      id.hashCode ^ assetPath.hashCode ^ isFaceUp.hashCode ^ isMatched.hashCode;
}