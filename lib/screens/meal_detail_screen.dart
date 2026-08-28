import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal.dart';
import '../services/favorites_provider.dart';
import '../services/meal_api.dart';
import '../widgets/async_view.dart';

/// Full recipe: hero image, ingredients, instructions, and external links.
/// Loads the detail by id so it works from any list (category, search, saved).
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final String mealId;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _api = MealApi();
  late Future<Meal?> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMealById(widget.mealId);
  }

  void _reload() => setState(() => _future = _api.fetchMealById(widget.mealId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<Meal?>(
        future: _future,
        onRetry: _reload,
        builder: (context, meal) {
          if (meal == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyView(
                message: 'This recipe is no longer available.',
              ),
            );
          }
          return _MealDetailBody(meal: meal);
        },
      ),
    );
  }
}

class _MealDetailBody extends StatelessWidget {
  const _MealDetailBody({required this.meal});

  final Meal meal;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isSaved = favorites.contains(meal.id);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(meal.name),
            background: CachedNetworkImage(
              imageUrl: meal.thumbnail,
              fit: BoxFit.cover,
              // Darken slightly so the overlaid title stays readable.
              color: Colors.black.withValues(alpha: 0.35),
              colorBlendMode: BlendMode.darken,
              placeholder: (_, _) => const ColoredBox(color: Colors.black12),
              errorWidget: (_, _, _) =>
                  const ColoredBox(color: Colors.black26),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
              tooltip: isSaved ? 'Remove from saved' : 'Save recipe',
              onPressed: () => favorites.toggle(meal.toSummary()),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(meal.category)),
                    Chip(label: Text(meal.area)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Ingredients', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                ...meal.ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7, right: 10),
                          child: Icon(Icons.circle, size: 6),
                        ),
                        Expanded(
                          child: Text(
                            ing.measure.isEmpty
                                ? ing.name
                                : '${ing.measure}  ${ing.name}',
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Instructions', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(meal.instructions, style: textTheme.bodyMedium),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (meal.youtubeUrl != null)
                      FilledButton.tonalIcon(
                        onPressed: () => _open(meal.youtubeUrl!),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Watch video'),
                      ),
                    if (meal.sourceUrl != null)
                      OutlinedButton.icon(
                        onPressed: () => _open(meal.sourceUrl!),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Source'),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
