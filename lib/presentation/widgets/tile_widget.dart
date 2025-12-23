import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/entities/tile_state.dart';

/// Individual tile widget with animations and interactions
class TileWidget extends StatefulWidget {
  final TileState tile;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double size;

  const TileWidget({
    super.key,
    required this.tile,
    required this.onTap,
    required this.onLongPress,
    this.size = 40.0,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _flagController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _flagScaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Reveal animation - improved for number tiles
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Scale animation: starts small, grows to normal size
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.elasticOut,
      ),
    );

    // Opacity animation: fades in
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOut,
      ),
    );

    // Flag animation
    _flagController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _flagScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 1.0,
      ),
    ]).animate(
      _flagController,
    );

    // Trigger animations based on tile state
    if (widget.tile.isRevealed) {
      _revealController.forward();
    }
    if (widget.tile.isFlagged) {
      _flagController.forward();
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate reveal
    if (!oldWidget.tile.isRevealed && widget.tile.isRevealed) {
      _revealController.forward();
    }

    // Animate flag - ensure flag stays visible if still flagged
    if (!oldWidget.tile.isFlagged && widget.tile.isFlagged) {
      _flagController.forward(from: 0.0);
    } else if (oldWidget.tile.isFlagged && !widget.tile.isFlagged) {
      _flagController.reverse();
    } else if (widget.tile.isFlagged) {
      // If tile is still flagged, ensure animation is at completed state
      if (_flagController.value < 1.0) {
        _flagController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    _flagController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.tile.isHidden) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.tile.isHidden && !widget.tile.isFlagged
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap();
            }
          : null,
      onLongPress: widget.tile.isHidden || widget.tile.isFlagged
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hidden tile background
              AnimatedOpacity(
                opacity: widget.tile.isHidden ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _buildHiddenTile(),
              ),
              // Revealed tile content with animation
              AnimatedBuilder(
                animation: _revealController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildRevealedTile(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenTile() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF2C2C2C)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark 
                ? const Color(0xFF1A1A1A)
                : theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: widget.tile.isFlagged
            ? Center(
                child: AnimatedBuilder(
                  animation: _flagScaleAnimation,
                  builder: (context, child) {
                    // Ensure flag is always visible when tile is flagged
                    // If animation hasn't started or completed, show at scale 1.0
                    final scale = _flagScaleAnimation.value > 0 
                        ? _flagScaleAnimation.value 
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.flag,
                        color: Color(0xFFE91E63), // Pink color matching the design
                        size: 20,
                      ),
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildRevealedTile() {
    if (!widget.tile.isRevealed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color backgroundColor;
    Widget? content;

    if (widget.tile.isMine) {
      backgroundColor = const Color(0xFF8B0000);
      content = FaIcon(
        FontAwesomeIcons.bomb,
        color: Colors.black,
        size: widget.size * 0.4,
      );
    } else if (widget.tile.isEmpty) {
      backgroundColor = isDark 
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFE8E8E8); // Lighter background for light mode
      content = null;
    } else {
      backgroundColor = isDark 
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFE8E8E8); // Lighter background for light mode
      final number = widget.tile.adjacentMines ?? 0;
      content = Text(
        number.toString(),
        style: TextStyle(
          color: _getNumberColor(number),
          fontSize: widget.size * 0.5,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFBDBDBD), // More visible border for light mode
            width: isDark ? 1 : 1.5, // Slightly thicker border in light mode
          ),
        ),
        child: content != null ? Center(child: content) : null,
      ),
    );
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.pink;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.white;
    }
  }
}

