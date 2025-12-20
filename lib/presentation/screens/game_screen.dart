import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_difficulty.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/status_bar.dart';
import '../widgets/win_animation.dart';
import '../widgets/mine_explosion.dart';

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
    ref.read(gameStateProvider.notifier).revealTile(row, col);

    final newState = ref.read(gameStateProvider);

    // Check if mine was hit or game won
    if (newState.status == GameStatus.lost) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _explosionPosition = Offset(screenSize.width / 2, screenSize.height / 2);
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showGameOverDialog = true;
          _showGameOverDialogIfNeeded(context, newState);
        }
      });
    } else if (newState.status == GameStatus.won) {
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mayın Tarlası',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                        onPressed: () => _showSettingsDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StatusBar(gameState: gameState),
                ),

                const SizedBox(height: 24),

                // Game board
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: GameBoard(
                        board: gameState.board,
                        onTileTap: _handleTileTap,
                        onTileLongPress: _handleTileLongPress,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _handleReset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yeniden Başla'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to main screen
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Ana Menü'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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


  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Ayarlar yakında eklenecek...',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

