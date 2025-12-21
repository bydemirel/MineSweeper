import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Settings screen with theme, sound, and haptic feedback options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? Colors.black.withOpacity(0.7)
          : Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                height: 1,
                thickness: 1,
              ),
              // Settings options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingOption(
                      icon: Icons.wb_sunny,
                      iconColor: Colors.yellow,
                      title: 'Theme',
                      subtitle: settings.isLightMode ? 'Light mode' : 'Dark mode',
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
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Minesweeper v1.0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A modern take on a classic puzzle game',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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

