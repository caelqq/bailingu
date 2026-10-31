import 'package:flutter/material.dart';

import 'add_word_screen.dart';
import 'game_screen.dart';
import 'games_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'results_screen.dart';
import 'ui.dart';
import 'words_screen.dart';

void main() => runApp(const BasahayApp());

class BasahayApp extends StatelessWidget {
  const BasahayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basahay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: C.background,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final Widget page = switch (settings.name) {
          '/games' => const GamesScreen(),
          '/game' => GameScreen(
            options: settings.arguments as GameOptions? ?? const GameOptions(),
          ),
          '/results' => ResultsScreen(
            args: settings.arguments as ResultsArgs? ?? const ResultsArgs(),
          ),
          '/words' => const WordsScreen(),
          '/add-word' => const AddWordScreen(),
          '/progress' => const ProgressScreen(),
          _ => const HomeScreen(),
        };
        // No slide animation: switching tabs feels like the web app.
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, a, b) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
