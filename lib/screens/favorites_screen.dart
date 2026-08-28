import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/favorites_provider.dart';
import '../widgets/async_view.dart';
import '../widgets/meal_card.dart';

/// Third tab: recipes the user has saved. Reads straight from
/// [FavoritesProvider], so it updates the moment a heart is tapped anywhere.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final saved = favorites.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved recipes')),
      body: !favorites.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? const EmptyView(
                  message: 'Tap the heart on any recipe to save it here.',
                  icon: Icons.favorite_border,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: saved.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => MealCard(meal: saved[i]),
                ),
    );
  }
}
