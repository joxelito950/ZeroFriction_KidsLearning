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
/// 3 huecos por cesta. La muestra de cada cesta dice qué va dentro; en las de
/// tamaño, la tarjeta y su muestra también son grandes, medianas o pequeñas
/// (P6), y cada objeto se pinta a su tamaño (3.4). Las reglas las decide el
/// cubit.
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

  /// Las cestas van por su id ([SortBasket.id]).
  final ShadowDropOutcome Function(String piece, ShadowBox box, Map<String, ShadowBox> baskets) onDrop;
  final ShadowDropOutcome Function(String piece, String basket) onMatch;

  /// Objeto que señala la mano del tutorial, con sus dos claves (HU-022).
  final String? hintPiece;
  final GlobalKey? hintPieceKey;
  final GlobalKey? hintBasketKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final SortBoard? board = state.board;
    final List<SortBasket> baskets = board?.baskets ?? const [];
    // En el nivel que se repone (4.3), la bandeja tiene huecos fijos.
    final bool refill = board?.trayCapacity != null;

    return PlaceBoardView(
      keyPrefix: 'sort',
      data: PlaceBoardData(
        boardId: state.round,
        pieces: [
          for (final SortPiece piece in state.pieces)
            BoardPiece(
              id: piece.id,
              symbol: piece.object.symbol,
              scale: piece.size.scale,
              semanticLabel: l10n.sortingObjectSemantics(pieceName(l10n, piece, board!.criterion)),
            ),
        ],
        targets: [
          for (final SortBasket basket in baskets)
            BoardTarget(
              id: basket.id,
              symbol: basket.sample.symbol,
              scale: basket.size?.cardScale ?? 1,
              semanticLabel: basketLabel(l10n, state, basket),
            ),
        ],
        targetOf: (id) => board!.targetOf(board.pieceById(id)).id,
        placedAt: (id) => [for (final SortPiece piece in state.placedAt(board!.basketById(id))) piece.id],
        isPlaced: state.placed.contains,
        canDrag: state.canDrag,
        coverageToSnap: state.coverageToSnap,
        placesFirst: state.basketsFirst,
        slots: SortLadder.maxPerBasket,
        // Con objetos pequeños, el reparto que da las piezas más grandes (3.4).
        balanced: true,
        trayLayout: refill
            ? [
                for (final (int index, String id) in state.traySlots.indexed)
                  id == SortGameState.emptySlot ? '#empty-$index' : id,
              ]
            : null,
      ),
      onGrab: onGrab,
      onDrop: onDrop,
      onMatch: onMatch,
      hintPiece: hintPiece,
      hintPieceKey: hintPieceKey,
      hintTargetKey: hintBasketKey,
    );
  }

  /// El nombre de un objeto y, si el tablero va por tamaño, su tamaño
  /// («Perro, tamaño pequeño»).
  static String pieceName(AppLocalizations l10n, SortPiece piece, SortCriterion criterion) {
    final String name = l10n.sortingObjectName(piece.object.name);
    return criterion == SortCriterion.color ? name : l10n.sortingWithSize(name, l10n.sortingSizeName(piece.size.name));
  }

  /// El nombre de una cesta: «Cesta roja», «Cesta, tamaño grande» o «Cesta
  /// roja, tamaño grande».
  static String basketName(AppLocalizations l10n, SortBasket basket) {
    final SortColor? color = basket.color;
    final SortSize? size = basket.size;
    if (color == null) return l10n.sortingSizeBasket(l10n.sortingSizeName(size!.name));
    final String name = l10n.sortingBasketName(color.name);
    return size == null ? name : l10n.sortingWithSize(name, l10n.sortingSizeName(size.name));
  }

  /// La cesta y lo que ya tiene («Cesta roja: Fresa, Tomate»).
  static String basketLabel(AppLocalizations l10n, SortGameState state, SortBasket basket) {
    final String name = basketName(l10n, basket);
    final List<SortPiece> here = state.placedAt(basket);
    if (here.isEmpty) return name;
    final SortCriterion criterion = state.board!.criterion;
    return l10n.sortingBasketWithSemantics(name, here.map((piece) => pieceName(l10n, piece, criterion)).join(', '));
  }
}
