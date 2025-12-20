import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_difficulty.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Main menu screen with difficulty selection
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each element
    // 0: Title, 1: Subtitle, 2: Easy, 3: Medium, 4: Hard, 5: Settings
    _fadeAnimations = List.generate(
      6,
      (index) {
        // Each animation starts at a delay and lasts for a duration
        // Total: 6 elements, each with 0.12 delay, 0.35 duration
        // Last element ends at: 5 * 0.12 + 0.35 = 0.95 (safe)
        final start = index * 0.12;
        final end = (start + 0.35).clamp(0.0, 1.0);
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end,
              curve: Curves.easeOut,
            ),
          ),
        );
      },
    );

    _slideAnimations = List.generate(
      6,
      (index) {
        // Each animation starts at a delay and lasts for a duration
        final start = index * 0.12;
        final end = (start + 0.35).clamp(0.0, 1.0);
        return Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end,
              curve: Curves.easeOutCubic,
            ),
          ),
        );
      },
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Title with gradient - animated
                SlideTransition(
                  position: _slideAnimations[0],
                  child: FadeTransition(
                    opacity: _fadeAnimations[0],
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF4FC3F7), // Light blue
                          Color(0xFFE91E63), // Pink
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'Minesweeper',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle - animated
                SlideTransition(
                  position: _slideAnimations[1],
                  child: FadeTransition(
                    opacity: _fadeAnimations[1],
                    child: const Text(
                      'A modern take on a classic puzzle',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Difficulty cards - animated
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _slideAnimations[2],
                        child: FadeTransition(
                          opacity: _fadeAnimations[2],
                          child: _DifficultyCard(
                            difficulty: GameDifficulty.easy,
                            iconColor: const Color(0xFF26A69A), // Teal
                            icon: Icons.star,
                            onTap: () => _navigateToGame(GameDifficulty.easy),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideAnimations[3],
                        child: FadeTransition(
                          opacity: _fadeAnimations[3],
                          child: _DifficultyCard(
                            difficulty: GameDifficulty.medium,
                            iconColor: const Color(0xFFFF9800), // Orange
                            icon: Icons.bolt,
                            onTap: () => _navigateToGame(GameDifficulty.medium),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideAnimations[4],
                        child: FadeTransition(
                          opacity: _fadeAnimations[4],
                          child: _DifficultyCard(
                            difficulty: GameDifficulty.hard,
                            iconColor: const Color(0xFFE91E63), // Pink/Red
                            icon: Icons.local_fire_department,
                            onTap: () => _navigateToGame(GameDifficulty.hard),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Settings button - animated
                SlideTransition(
                  position: _slideAnimations[5],
                  child: FadeTransition(
                    opacity: _fadeAnimations[5],
                    child: _SettingsButton(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGame(GameDifficulty difficulty) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(initialDifficulty: difficulty),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final GameDifficulty difficulty;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${difficulty.rows}x${difficulty.cols} • ${difficulty.mineCount} mines',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron icon
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

