import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'services/favorites_provider.dart';
import 'theme.dart';

void main() {
  runApp(const SkilletApp());
}

class SkilletApp extends StatelessWidget {
  const SkilletApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The favorites store is created once and shared with the whole tree.
    // `..load()` kicks off the disk read immediately; screens show a spinner
    // until `isLoaded` flips true.
    return ChangeNotifierProvider(
      create: (_) => FavoritesProvider()..load(),
      child: MaterialApp(
        title: 'Skillet',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}
