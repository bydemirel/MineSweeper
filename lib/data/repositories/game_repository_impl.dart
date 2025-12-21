import 'dart:math';
import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_difficulty.dart';
import '../../domain/entities/tile_state.dart';

/// Implementation of GameRepository
class GameRepositoryImpl implements GameRepository {
  final Random _random = Random();

  @override
  GameState createGame(GameDifficulty difficulty) {
    final board = List.generate(
      difficulty.rows,
      (row) => List.generate(
        difficulty.cols,
        (col) => TileState(
          row: row,
          col: col,
          type: TileType.empty,
          status: TileStatus.hidden,
        ),
      ),
    );

    return GameState(
      board: board,
      difficulty: difficulty,
      status: GameStatus.notStarted,
      minesRemaining: difficulty.mineCount,
      isFirstClick: true,
    );
  }

  @override
  GameState revealTile(GameState gameState, int row, int col) {
    if (gameState.isGameOver) return gameState;

    final board = gameState.board.map((r) => r.map((t) => t).toList()).toList();
    final tile = board[row][col];

    // Can't reveal flagged tiles (flag is a marker, must be removed first)
    if (tile.isFlagged) return gameState;
    
    // Can't reveal already revealed tiles
    if (tile.isRevealed) return gameState;

    // First click: generate mines ensuring this tile is safe
    if (gameState.isFirstClick) {
      // Save all flag states before generating mines
      final flagStates = <String, TileStatus>{};
      for (int r = 0; r < board.length; r++) {
        for (int c = 0; c < board[r].length; c++) {
          if (board[r][c].isFlagged) {
            flagStates['$r,$c'] = board[r][c].status;
          }
        }
      }

      board[row][col] = tile.copyWith(status: TileStatus.revealed);
      final boardWithMines = generateMines(
        board,
        gameState.difficulty.mineCount,
        row,
        col,
      );
      final boardWithNumbers = calculateAdjacentMines(boardWithMines);
      
      // Restore flag states after mine generation
      for (final entry in flagStates.entries) {
        final coords = entry.key.split(',');
        final r = int.parse(coords[0]);
        final c = int.parse(coords[1]);
        if (r < boardWithNumbers.length && c < boardWithNumbers[r].length) {
          boardWithNumbers[r][c] = boardWithNumbers[r][c].copyWith(
            status: entry.value,
          );
        }
      }
      
      final revealedBoard = revealEmptyTiles(boardWithNumbers, row, col);

      final newStatus = checkWin(
            GameState(
              board: revealedBoard,
              difficulty: gameState.difficulty,
              status: GameStatus.playing,
              minesRemaining: gameState.difficulty.mineCount,
              isFirstClick: false,
              startTime: DateTime.now(),
            ),
          )
          ? GameStatus.won
          : GameStatus.playing;

      return GameState(
        board: revealedBoard,
        difficulty: gameState.difficulty,
        status: newStatus,
        minesRemaining: gameState.difficulty.mineCount,
        isFirstClick: false,
        startTime: DateTime.now(),
      );
    }

    // Regular reveal
    if (tile.isMine) {
      // Game over - reveal all mines
      for (int r = 0; r < board.length; r++) {
        for (int c = 0; c < board[r].length; c++) {
          if (board[r][c].isMine) {
            board[r][c] = board[r][c].copyWith(status: TileStatus.revealed);
          }
        }
      }
      return gameState.copyWith(
        board: board,
        status: GameStatus.lost,
      );
    }

    // Reveal tile and adjacent empty tiles
    final revealedBoard = revealEmptyTiles(board, row, col);
    final newGameState = gameState.copyWith(
      board: revealedBoard,
      status: GameStatus.playing,
      isFirstClick: false,
    );

    final isWon = checkWin(newGameState);
    return newGameState.copyWith(
      status: isWon ? GameStatus.won : GameStatus.playing,
    );
  }

  @override
  GameState toggleFlag(GameState gameState, int row, int col) {
    if (gameState.isGameOver) return gameState;

    final board = gameState.board.map((r) => r.map((t) => t).toList()).toList();
    final tile = board[row][col];

    // Can't flag revealed tiles (only hidden tiles can be flagged)
    if (tile.isRevealed) return gameState;

    // Toggle flag: if flagged, remove flag (set to hidden); if not flagged, add flag
    final newStatus = tile.status == TileStatus.flagged 
        ? TileStatus.hidden 
        : TileStatus.flagged;
    board[row][col] = tile.copyWith(status: newStatus);

    final flagsPlaced = gameState.flagsPlaced +
        (newStatus == TileStatus.flagged ? 1 : -1);
    final minesRemaining = gameState.difficulty.mineCount - flagsPlaced;

    return gameState.copyWith(
      board: board,
      flagsPlaced: flagsPlaced,
      minesRemaining: minesRemaining.clamp(0, gameState.difficulty.mineCount),
    );
  }

  @override
  List<List<TileState>> generateMines(
    List<List<TileState>> board,
    int mineCount,
    int safeRow,
    int safeCol,
  ) {
    final rows = board.length;
    final cols = board[0].length;
    final totalTiles = rows * cols;
    final safeIndex = safeRow * cols + safeCol;

    // Generate mine positions
    final minePositions = <int>{};
    while (minePositions.length < mineCount) {
      final position = _random.nextInt(totalTiles);
      // Ensure safe tile and its neighbors are not mines
      if (position != safeIndex &&
          !_isAdjacent(position, safeIndex, cols, rows)) {
        minePositions.add(position);
      }
    }

    // Place mines
    for (final position in minePositions) {
      final row = position ~/ cols;
      final col = position % cols;
      // Preserve the existing status (flag, hidden, revealed)
      final currentTile = board[row][col];
      board[row][col] = currentTile.copyWith(
        type: TileType.mine,
        status: currentTile.status, // Preserve flag status
      );
    }

    return board;
  }

  bool _isAdjacent(int pos1, int pos2, int cols, int rows) {
    final row1 = pos1 ~/ cols;
    final col1 = pos1 % cols;
    final row2 = pos2 ~/ cols;
    final col2 = pos2 % cols;

    return (row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1;
  }

  @override
  List<List<TileState>> calculateAdjacentMines(List<List<TileState>> board) {
    final rows = board.length;
    final cols = board[0].length;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (board[row][col].isMine) continue;

        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = row + dr;
            final nc = col + dc;
            if (nr >= 0 &&
                nr < rows &&
                nc >= 0 &&
                nc < cols &&
                board[nr][nc].isMine) {
              count++;
            }
          }
        }

        // Preserve the existing status (flag, hidden, revealed)
        final currentTile = board[row][col];
        board[row][col] = currentTile.copyWith(
          type: count > 0 ? TileType.number : TileType.empty,
          adjacentMines: count > 0 ? count : null,
          status: currentTile.status, // Preserve flag status
        );
      }
    }

    return board;
  }

  @override
  List<List<TileState>> revealEmptyTiles(
    List<List<TileState>> board,
    int row,
    int col,
  ) {
    if (row < 0 ||
        row >= board.length ||
        col < 0 ||
        col >= board[0].length) {
      return board;
    }

    final tile = board[row][col];
    if (tile.isRevealed || tile.isFlagged || tile.isMine) {
      return board;
    }

    // Reveal current tile
    board[row][col] = tile.copyWith(status: TileStatus.revealed);

    // If it's a number, stop recursion
    if (tile.isNumber) {
      return board;
    }

    // Recursively reveal adjacent tiles
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        revealEmptyTiles(board, row + dr, col + dc);
      }
    }

    return board;
  }

  @override
  bool checkWin(GameState gameState) {
    final totalTiles = gameState.totalTiles;
    final revealedTiles = gameState.revealedTiles;
    final mineCount = gameState.difficulty.mineCount;

    // Win condition: all non-mine tiles are revealed
    return revealedTiles == (totalTiles - mineCount);
  }

  @override
  GameState resetGame(GameState gameState) {
    return createGame(gameState.difficulty);
  }
}

