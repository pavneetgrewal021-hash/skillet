import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api.dart';
import '../widgets/async_view.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart';

/// First tab: a grid of every recipe category, plus a "Surprise me" action
/// that jumps straight to a random recipe.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = MealApi();
  late Future<List<Category>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchCategories();
  }

  void _reload() => setState(() => _future = _api.fetchCategories());

  Future<void> _openRandomMeal() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final meal = await _api.fetchRandomMeal();
      await navigator.push(
        MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Surprise me',
            onPressed: _openRandomMeal,
          ),
        ],
      ),
      body: AsyncView<List<Category>>(
        future: _future,
        onRetry: _reload,
        builder: (context, categories) {
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) =>
                  _CategoryCard(category: categories[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryMealsScreen(category: category.name),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: category.thumbnail,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: Colors.black12),
                errorWidget: (_, _, _) => const Icon(Icons.restaurant),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
