import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../screens/meal_detail_screen.dart';
import '../services/favorites_provider.dart';

/// A horizontal list row for one meal: thumbnail, name, and a favorite toggle.
/// Tapping the row opens the full recipe.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});

  final MealSummary meal;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isSaved = favorites.contains(meal.id);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MealDetailScreen(mealId: meal.id),
          ),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: meal.thumbnail,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (_, _) => const SizedBox(
                width: 96,
                height: 96,
                child: ColoredBox(color: Colors.black12),
              ),
              errorWidget: (_, _, _) => const SizedBox(
                width: 96,
                height: 96,
                child: Icon(Icons.restaurant),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  meal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
              color: isSaved ? Theme.of(context).colorScheme.primary : null,
              tooltip: isSaved ? 'Remove from saved' : 'Save recipe',
              onPressed: () => favorites.toggle(meal),
            ),
          ],
        ),
      ),
    );
  }
}
