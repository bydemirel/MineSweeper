import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';

/// Status bar showing game information
class StatusBar extends StatelessWidget {
  final GameState gameState;

  const StatusBar({
    super.key,
    required this.gameState,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final elapsedTime = gameState.elapsedTime ?? Duration.zero;
    final displayTime = gameState.status == GameStatus.playing ||
            gameState.status == GameStatus.won ||
            gameState.status == GameStatus.lost
        ? _formatDuration(elapsedTime)
        : '00:00';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.flag,
            label: 'Mayın',
            value: gameState.minesRemaining.toString(),
            color: Colors.red,
          ),
          _buildStatItem(
            icon: Icons.timer,
            label: 'Süre',
            value: displayTime,
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: _getStatusIcon(),
            label: _getStatusLabel(),
            value: '',
            color: _getStatusColor(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (gameState.status) {
      case GameStatus.notStarted:
        return Icons.play_circle_outline;
      case GameStatus.playing:
        return Icons.play_circle;
      case GameStatus.won:
        return Icons.check_circle;
      case GameStatus.lost:
        return Icons.cancel;
    }
  }

  String _getStatusLabel() {
    switch (gameState.status) {
      case GameStatus.notStarted:
        return 'Başla';
      case GameStatus.playing:
        return 'Oynuyor';
      case GameStatus.won:
        return 'Kazandın!';
      case GameStatus.lost:
        return 'Kaybettin';
    }
  }

  Color _getStatusColor() {
    switch (gameState.status) {
      case GameStatus.notStarted:
        return Colors.grey;
      case GameStatus.playing:
        return Colors.blue;
      case GameStatus.won:
        return Colors.green;
      case GameStatus.lost:
        return Colors.red;
    }
  }
}

