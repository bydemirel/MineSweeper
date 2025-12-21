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
    final containerPadding = 8.0;
    final availableWidth = screenWidth - 32 - (containerPadding * 2); // Screen padding + container padding
    final availableHeightForTiles = availableHeight - (containerPadding * 2); // Container padding

    final rows = board.length;
    final cols = board[0].length;

    // Calculate tile size to fit screen
    // Account for margins between tiles (each tile has padding on all sides)
    final tileMargin = 2.0; // Margin between tiles
    final totalMarginPerTile = tileMargin * 2; // Left + right margin per tile
    
    final tileWidth = (availableWidth - (totalMarginPerTile * cols)) / cols;
    final tileHeight = (availableHeightForTiles - (totalMarginPerTile * rows)) / rows;
    final tileSize = (tileWidth < tileHeight ? tileWidth : tileHeight);

    final theme = Theme.of(context);
    
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(cols, (col) {
                return Padding(
                  padding: EdgeInsets.all(tileMargin),
                  child: TileWidget(
                    tile: board[row][col],
                    onTap: () => onTileTap(row, col),
                    onLongPress: () => onTileLongPress(row, col),
                    size: tileSize,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

