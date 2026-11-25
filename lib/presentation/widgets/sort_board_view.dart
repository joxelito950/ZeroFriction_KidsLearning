import 'package:flutter/material.dart';

import '../../domain/shadows/shadow_drop.dart';
import '../../domain/sorting/sort_board.dart';
import '../../domain/sorting/sort_catalog.dart';
import '../../domain/sorting/sort_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/sort_game/sort_game_state.dart';
import 'place_board_view.dart';

/// Tablero de «Clasificar» (HU-027 3.1): el tablero de destinos común
/// ([PlaceBoardView]) con los objetos como piezas y las cestas como destinos,
/// 3 huecos por cesta. La muestra de cada cesta dice qué va dentro. Las reglas
/// las decide el cubit.
class SortBoardView extends StatelessWidget {
  const SortBoardView({
    super.key,
    required this.state,
    required this.onGrab,
    required this.onDrop,
    required this.onMatch,
    this.hintPiece,
    this.hintPieceKey,
    this.hintBasketKey,
  });

  final SortGameState state;
  final ValueChanged<String> onGrab;
  final ShadowDropOutcome Function(String piece, ShadowBox box, Map<SortColor, ShadowBox> baskets) onDrop;
  final ShadowDropOutcome Function(String piece, SortColor basket) onMatch;

  /// Objeto que señala la mano del tutorial, con sus dos claves (HU-022).
  final String? hintPiece;
  final GlobalKey? hintPieceKey;
  final GlobalKey? hintBasketKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final SortBoard? board = state.board;
    final List<SortColor> baskets = board?.baskets ?? const [];
    SortColor basket(String id) => SortColor.values.byName(id);

    return PlaceBoardView(
      keyPrefix: 'sort',
      data: PlaceBoardData(
        boardId: state.round,
        pieces: [
          for (final SortPiece piece in state.pieces)
            BoardPiece(
              id: piece.id,
              symbol: piece.object.symbol,
              semanticLabel: l10n.sortingObjectSemantics(l10n.sortingObjectName(piece.object.name)),
            ),
        ],
        targets: [
          for (final SortColor each in baskets)
            BoardTarget(id: each.name, symbol: each.sample.symbol, semanticLabel: basketLabel(l10n, state, each)),
        ],
        targetOf: (id) => board!.pieceById(id).color.name,
        placedAt: (id) => [for (final SortPiece piece in state.placedAt(basket(id))) piece.id],
        isPlaced: state.placed.contains,
        canDrag: state.canDrag,
        coverageToSnap: state.coverageToSnap,
        placesFirst: state.basketsFirst,
        slots: SortLadder.maxPerBasket,
      ),
      onGrab: onGrab,
      onDrop: (id, box, targets) =>
          onDrop(id, box, {for (final entry in targets.entries) basket(entry.key): entry.value}),
      onMatch: (id, target) => onMatch(id, basket(target)),
      hintPiece: hintPiece,
      hintPieceKey: hintPieceKey,
      hintTargetKey: hintBasketKey,
    );
  }

  /// La cesta y lo que ya tiene («Cesta roja: Fresa, Tomate»).
  static String basketLabel(AppLocalizations l10n, SortGameState state, SortColor basket) {
    final String name = l10n.sortingBasketName(basket.name);
    final List<SortPiece> here = state.placedAt(basket);
    if (here.isEmpty) return name;
    return l10n.sortingBasketWithSemantics(
        name, here.map((piece) => l10n.sortingObjectName(piece.object.name)).join(', '));
  }
}
