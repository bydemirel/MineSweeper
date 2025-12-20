import '../entities/game_state.dart';
import '../entities/game_difficulty.dart';
import '../entities/tile_state.dart';

/// Repository interface for game operations
abstract class GameRepository {
  /// Creates a new game board with the specified difficulty
  GameState createGame(GameDifficulty difficulty);

  /// Reveals a tile at the given position
  GameState revealTile(GameState gameState, int row, int col);

  /// Toggles flag on a tile at the given position
  GameState toggleFlag(GameState gameState, int row, int col);

  /// Generates mines on the board, ensuring the first clicked tile is safe
  List<List<TileState>> generateMines(
    List<List<TileState>> board,
    int mineCount,
    int safeRow,
    int safeCol,
  );

  /// Calculates adjacent mine counts for all tiles
  List<List<TileState>> calculateAdjacentMines(List<List<TileState>> board);

  /// Recursively reveals empty tiles and adjacent number tiles
  List<List<TileState>> revealEmptyTiles(
    List<List<TileState>> board,
    int row,
    int col,
  );

  /// Checks if the game is won
  bool checkWin(GameState gameState);

  /// Resets the game to initial state
  GameState resetGame(GameState gameState);
}

