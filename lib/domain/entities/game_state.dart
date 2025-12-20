import 'package:equatable/equatable.dart';
import 'tile_state.dart';
import 'game_difficulty.dart';

enum GameStatus {
  notStarted,
  playing,
  won,
  lost,
}

/// Represents the complete state of the game
class GameState extends Equatable {
  final List<List<TileState>> board;
  final GameDifficulty difficulty;
  final GameStatus status;
  final int flagsPlaced;
  final int minesRemaining;
  final bool isFirstClick;
  final DateTime? startTime;
  final Duration? elapsedTime;

  const GameState({
    required this.board,
    required this.difficulty,
    this.status = GameStatus.notStarted,
    this.flagsPlaced = 0,
    this.minesRemaining = 0,
    this.isFirstClick = true,
    this.startTime,
    this.elapsedTime,
  });

  GameState copyWith({
    List<List<TileState>>? board,
    GameDifficulty? difficulty,
    GameStatus? status,
    int? flagsPlaced,
    int? minesRemaining,
    bool? isFirstClick,
    DateTime? startTime,
    Duration? elapsedTime,
  }) {
    return GameState(
      board: board ?? this.board,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      flagsPlaced: flagsPlaced ?? this.flagsPlaced,
      minesRemaining: minesRemaining ?? this.minesRemaining,
      isFirstClick: isFirstClick ?? this.isFirstClick,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }

  int get totalMines => difficulty.mineCount;
  int get totalTiles => difficulty.rows * difficulty.cols;
  int get revealedTiles {
    return board.expand((row) => row).where((tile) => tile.isRevealed).length;
  }

  bool get isGameOver => status == GameStatus.won || status == GameStatus.lost;
  bool get isGameWon => status == GameStatus.won;
  bool get isGameLost => status == GameStatus.lost;

  @override
  List<Object?> get props => [
        board,
        difficulty,
        status,
        flagsPlaced,
        minesRemaining,
        isFirstClick,
        startTime,
        elapsedTime,
      ];
}

