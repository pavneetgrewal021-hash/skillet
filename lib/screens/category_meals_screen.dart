import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api.dart';
import '../widgets/async_view.dart';
import '../widgets/meal_card.dart';

/// Second-level screen: every meal in one category.
class CategoryMealsScreen extends StatefulWidget {
  const CategoryMealsScreen({super.key, required this.category});

  final String category;

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  final _api = MealApi();
  late Future<List<MealSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMealsByCategory(widget.category);
  }

  void _reload() =>
      setState(() => _future = _api.fetchMealsByCategory(widget.category));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: AsyncView<List<MealSummary>>(
        future: _future,
        onRetry: _reload,
        builder: (context, meals) {
          if (meals.isEmpty) {
            return const EmptyView(message: 'No recipes in this category yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: meals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => MealCard(meal: meals[i]),
          );
        },
      ),
    );
  }
}
