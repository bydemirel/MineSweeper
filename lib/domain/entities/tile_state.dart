import 'package:equatable/equatable.dart';

/// Represents the state of a single tile on the game board
enum TileType {
  empty,
  number,
  mine,
}

enum TileStatus {
  hidden,
  revealed,
  flagged,
}

class TileState extends Equatable {
  final int row;
  final int col;
  final TileType type;
  final TileStatus status;
  final int? adjacentMines; // null for empty, 0-8 for numbers

  const TileState({
    required this.row,
    required this.col,
    required this.type,
    this.status = TileStatus.hidden,
    this.adjacentMines,
  });

  TileState copyWith({
    TileType? type,
    TileStatus? status,
    int? adjacentMines,
  }) {
    return TileState(
      row: row,
      col: col,
      type: type ?? this.type,
      status: status ?? this.status,
      adjacentMines: adjacentMines ?? this.adjacentMines,
    );
  }

  bool get isMine => type == TileType.mine;
  bool get isEmpty => type == TileType.empty;
  bool get isNumber => type == TileType.number;
  bool get isHidden => status == TileStatus.hidden || status == TileStatus.flagged;
  bool get isRevealed => status == TileStatus.revealed;
  bool get isFlagged => status == TileStatus.flagged;

  @override
  List<Object?> get props => [row, col, type, status, adjacentMines];
}

