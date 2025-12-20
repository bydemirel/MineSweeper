/// Represents game difficulty levels
enum GameDifficulty {
  easy,
  medium,
  hard,
}

extension GameDifficultyExtension on GameDifficulty {
  int get rows {
    switch (this) {
      case GameDifficulty.easy:
        return 8;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 12;
    }
  }

  int get cols {
    switch (this) {
      case GameDifficulty.easy:
        return 8;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 12;
    }
  }

  int get mineCount {
    switch (this) {
      case GameDifficulty.easy:
        return 10;
      case GameDifficulty.medium:
        return 20;
      case GameDifficulty.hard:
        return 35;
    }
  }

  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }
}

