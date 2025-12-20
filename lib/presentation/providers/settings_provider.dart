import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings state
class SettingsState {
  final bool isLightMode;
  final bool soundEffectsEnabled;
  final bool hapticFeedbackEnabled;

  const SettingsState({
    this.isLightMode = false,
    this.soundEffectsEnabled = false,
    this.hapticFeedbackEnabled = true,
  });

  SettingsState copyWith({
    bool? isLightMode,
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return SettingsState(
      isLightMode: isLightMode ?? this.isLightMode,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleTheme() {
    state = state.copyWith(isLightMode: !state.isLightMode);
  }

  void toggleSoundEffects() {
    state = state.copyWith(soundEffectsEnabled: !state.soundEffectsEnabled);
  }

  void toggleHapticFeedback() {
    state = state.copyWith(hapticFeedbackEnabled: !state.hapticFeedbackEnabled);
  }
}

