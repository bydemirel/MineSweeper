import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Settings screen with theme, sound, and haptic feedback options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xB3000000), // Colors.black.withOpacity(0.7)
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2C2C2C), height: 1, thickness: 1),
              // Settings options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingOption(
                      icon: Icons.wb_sunny,
                      iconColor: Colors.yellow,
                      title: 'Theme',
                      subtitle: 'Light mode',
                      value: settings.isLightMode,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).toggleTheme();
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingOption(
                      icon: Icons.volume_up,
                      iconColor: Colors.green,
                      title: 'Sound Effects',
                      subtitle: 'Tile sounds and feedback',
                      value: settings.soundEffectsEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).toggleSoundEffects();
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingOption(
                      icon: Icons.vibration,
                      iconColor: Colors.purple,
                      title: 'Haptic Feedback',
                      subtitle: 'Vibration on interactions',
                      value: settings.hapticFeedbackEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(settingsProvider.notifier).toggleHapticFeedback();
                      },
                    ),
                  ],
                ),
              ),
              // Game info section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      'Minesweeper v1.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'A modern take on a classic puzzle game',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Done button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  height: 50,
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
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // Using withOpacity for simplicity - deprecated but functional
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
          // Toggle switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: iconColor,
            inactiveThumbColor: Colors.grey[300],
            inactiveTrackColor: Colors.grey[700],
          ),
        ],
      ),
    );
  }
}

