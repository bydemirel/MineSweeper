import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: MinefieldApp(),
    ),
  );
}

class MinefieldApp extends ConsumerWidget {
  const MinefieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'Minefield',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: settings.isLightMode ? ThemeMode.light : ThemeMode.dark,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Color(0xFFF5F5F5),
        background: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E1E1E),
        onBackground: Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE0E0E0),
        foregroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

