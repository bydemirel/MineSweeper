import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_difficulty.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/game_repository_impl.dart';

/// Provider for game repository
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl();
});

/// Provider for game state
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  final repository = ref.watch(gameRepositoryProvider);
  return GameStateNotifier(repository);
});

/// Notifier for managing game state
class GameStateNotifier extends StateNotifier<GameState> {
  final GameRepository _repository;

  GameStateNotifier(this._repository)
      : super(_repository.createGame(GameDifficulty.easy));

  /// Creates a new game with specified difficulty
  void newGame(GameDifficulty difficulty) {
    state = _repository.createGame(difficulty);
  }

  /// Reveals a tile
  void revealTile(int row, int col) {
    state = _repository.revealTile(state, row, col);
  }

  /// Toggles flag on a tile
  void toggleFlag(int row, int col) {
    state = _repository.toggleFlag(state, row, col);
  }

  /// Resets the current game
  void resetGame() {
    state = _repository.resetGame(state);
  }

  /// Updates elapsed time
  void updateElapsedTime(Duration elapsed) {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(elapsedTime: elapsed);
    }
  }
}

