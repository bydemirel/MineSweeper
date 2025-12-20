import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_difficulty.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/win_animation.dart';
import '../widgets/mine_explosion.dart';
import 'settings_screen.dart';

/// Main game screen
class GameScreen extends ConsumerStatefulWidget {
  final GameDifficulty? initialDifficulty;

  const GameScreen({
    super.key,
    this.initialDifficulty,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Offset? _explosionPosition;
  bool _showGameOverDialog = false;
  bool _flagModeActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize game with selected difficulty if provided
    if (widget.initialDifficulty != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameStateProvider.notifier).newGame(widget.initialDifficulty!);
      });
    }
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final gameState = ref.read(gameStateProvider);
      if (gameState.status == GameStatus.playing) {
        final now = DateTime.now();
        if (gameState.startTime != null) {
          final elapsed = now.difference(gameState.startTime!);
          ref.read(gameStateProvider.notifier).updateElapsedTime(elapsed);
        }
      }

      _startTimer();
    });
  }

  void _handleTileTap(int row, int col) {
    final gameState = ref.read(gameStateProvider);
    final tile = gameState.board[row][col];

    // If flag mode is active, toggle flag
    if (_flagModeActive) {
      ref.read(gameStateProvider.notifier).toggleFlag(row, col);
      return;
    }

    // If tile is flagged, do nothing (flag is just a marker)
    // Flag must be removed in flag mode before revealing
    if (tile.isFlagged) {
      HapticFeedback.lightImpact();
      // Show a brief message that flag must be removed first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bayraklı kareyi açmak için önce bayrağı kaldırın'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If tile is already revealed, do nothing
    if (tile.isRevealed) {
      return;
    }

    // Reveal the tile
    ref.read(gameStateProvider.notifier).revealTile(row, col);

    final newState = ref.read(gameStateProvider);

    // Check if mine was hit or game won
    if (newState.status == GameStatus.lost) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _explosionPosition = Offset(screenSize.width / 2, screenSize.height / 2);
        _flagModeActive = false; // Disable flag mode on game over
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showGameOverDialog = true;
          _showGameOverDialogIfNeeded(context, newState);
        }
      });
    } else if (newState.status == GameStatus.won) {
      setState(() {
        _flagModeActive = false; // Disable flag mode on win
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _showGameOverDialog = true;
          _showGameOverDialogIfNeeded(context, newState);
        }
      });
    }
  }

  void _handleTileLongPress(int row, int col) {
    ref.read(gameStateProvider.notifier).toggleFlag(row, col);
  }


  void _handleReset() {
    ref.read(gameStateProvider.notifier).resetGame();
    setState(() {
      _explosionPosition = null;
      _showGameOverDialog = false;
      _flagModeActive = false; // Reset flag mode
    });
    HapticFeedback.lightImpact();
  }

  void _showGameOverDialogIfNeeded(BuildContext context, GameState gameState) {
    if (_showGameOverDialog && gameState.isGameOver) {
      _showGameOverDialog = false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGameOverDialog(gameState),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final elapsedTime = gameState.elapsedTime ?? Duration.zero;
    final displayTime = gameState.status == GameStatus.playing ||
            gameState.status == GameStatus.won ||
            gameState.status == GameStatus.lost
        ? '${elapsedTime.inSeconds}s'
        : '0s';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top navigation bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF2C2C2C),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF4FC3F7),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Flag count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${gameState.minesRemaining}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Refresh button
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _handleReset,
                      ),
                      // Settings button
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Game board
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: GameBoard(
                        board: gameState.board,
                        onTileTap: _handleTileTap,
                        onTileLongPress: _handleTileLongPress,
                      ),
                    ),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Flag Mode button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _flagModeActive = !_flagModeActive;
                            });
                            HapticFeedback.mediumImpact();
                          },
                          icon: const Icon(Icons.flag),
                          label: Text(_flagModeActive ? 'Bayrak Modu Aktif' : 'Bayrak Ekle'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _flagModeActive
                                ? const Color(0xFFE91E63) // Pink/Red when active
                                : const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Instructions
                      Text(
                        _flagModeActive
                            ? 'Şüphelendiğin karelere tıkla'
                            : 'Tap to reveal • Long press to flag',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Win animation overlay
            if (gameState.isGameWon)
              WinAnimation(isActive: gameState.isGameWon),

            // Explosion animation overlay
            if (_explosionPosition != null)
              MineExplosion(
                isActive: gameState.isGameLost,
                position: _explosionPosition!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverDialog(GameState gameState) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gameState.isGameWon
                ? Icons.celebration
                : Icons.sentiment_very_dissatisfied,
            size: 64,
            color: gameState.isGameWon ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            gameState.isGameWon ? 'Tebrikler!' : 'Oyun Bitti',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gameState.isGameWon
                ? 'Tüm mayınları buldun!'
                : 'Bir mayına bastın!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (gameState.isGameWon && gameState.elapsedTime != null) ...[
            const SizedBox(height: 16),
            Text(
              'Süre: ${_formatDuration(gameState.elapsedTime!)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleReset();
                },
                child: const Text('Yeniden Başla'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to main screen
                },
                child: const Text('Ana Menü'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


}

