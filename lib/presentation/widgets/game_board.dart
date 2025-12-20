import 'package:flutter/material.dart';
import '../../domain/entities/tile_state.dart';
import 'tile_widget.dart';

/// Game board widget with optimized rendering
class GameBoard extends StatelessWidget {
  final List<List<TileState>> board;
  final Function(int row, int col) onTileTap;
  final Function(int row, int col) onTileLongPress;

  const GameBoard({
    super.key,
    required this.board,
    required this.onTileTap,
    required this.onTileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (board.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.6;
    final availableWidth = screenWidth - 32; // Padding

    final rows = board.length;
    final cols = board[0].length;

    // Calculate tile size to fit screen
    final tileWidth = availableWidth / cols;
    final tileHeight = availableHeight / rows;
    final tileSize = (tileWidth < tileHeight ? tileWidth : tileHeight) - 2;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(cols, (col) {
                return TileWidget(
                  tile: board[row][col],
                  onTap: () => onTileTap(row, col),
                  onLongPress: () => onTileLongPress(row, col),
                  size: tileSize,
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

