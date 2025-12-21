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
    // If flag mode is active, toggle flag (always allow toggle in flag mode)
    if (_flagModeActive) {
      ref.read(gameStateProvider.notifier).toggleFlag(row, col);
      return;
    }

    final gameState = ref.read(gameStateProvider);
    final tile = gameState.board[row][col];

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
    final theme = Theme.of(context);
    final gameState = ref.watch(gameStateProvider);
    final elapsedTime = gameState.elapsedTime ?? Duration.zero;
    final displayTime = gameState.status == GameStatus.playing ||
            gameState.status == GameStatus.won ||
            gameState.status == GameStatus.lost
        ? '${elapsedTime.inSeconds}s'
        : '0s';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top navigation bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: theme.colorScheme.surface,
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
                          color: theme.colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              displayTime,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
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
                          color: theme.colorScheme.surface.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Color(0xFFE91E63), // Pink color
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${gameState.minesRemaining}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
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
                        icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
                        onPressed: _handleReset,
                      ),
                      // Settings button
                      IconButton(
                        icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
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
                      // Flag Mode button - commented out for now
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     onPressed: () {
                      //       setState(() {
                      //         _flagModeActive = !_flagModeActive;
                      //       });
                      //       HapticFeedback.mediumImpact();
                      //     },
                      //     icon: const Icon(Icons.flag),
                      //     label: Text(_flagModeActive ? 'Bayrak Modu Aktif' : 'Bayrak Ekle'),
                      //     style: ElevatedButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       backgroundColor: _flagModeActive
                      //           ? const Color(0xFFE91E63) // Pink/Red when active
                      //           : const Color(0xFF2C2C2C),
                      //       foregroundColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      // Instructions
                      Text(
                        'Tap to reveal • Long press to flag',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
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
    final theme = Theme.of(context);
    
    if (gameState.isGameWon) {
      // Win dialog (keep existing design for win)
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm mayınları buldun!',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (gameState.elapsedTime != null) ...[
              const SizedBox(height: 16),
              Text(
                'Süre: ${_formatDuration(gameState.elapsedTime!)}',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.primary,
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ana Menü'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Game Over dialog (new design matching the image)
    final isDark = theme.brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D1B4E), // Dark purple
                    Color(0xFF4A2C5A), // Dark pink-purple
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.9),
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63), // Pinkish-red
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Game Over',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              'You hit a mine. Better luck next time!',
              style: TextStyle(
                fontSize: 16,
                color: isDark 
                    ? const Color(0xFFB0B0B0)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Play Again button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4FC3F7), // Blue
                      Color(0xFF9C27B0), // Purple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _handleReset();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Back to Home button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A4C93), // Dark purple
                      Color(0xFF8B5A6B), // Purple-brown
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Go back to main screen
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


}

