import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api.dart';
import '../widgets/async_view.dart';
import '../widgets/meal_card.dart';

/// Second tab: debounced free-text search by meal name.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = MealApi();
  final _controller = TextEditingController();

  Timer? _debounce;
  String _query = '';
  Future<List<Meal>>? _future;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so the clear button appears/disappears
    // immediately, even though the network call itself is debounced.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      setState(() {
        _query = q;
        _future = q.isEmpty ? null : _api.searchMealsByName(q);
      });
    });
  }

  void _retry() {
    setState(() => _future = _api.searchMealsByName(_query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Try "chicken", "pasta", "pie"…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: _future == null
          ? const EmptyView(
              message: 'Search thousands of recipes by name.',
              icon: Icons.search,
            )
          : AsyncView<List<Meal>>(
              key: ValueKey(_query),
              future: _future!,
              onRetry: _retry,
              builder: (context, meals) {
                if (meals.isEmpty) {
                  return EmptyView(
                    message: 'No recipes found for "$_query".',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: meals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      MealCard(meal: meals[i].toSummary()),
                );
              },
            ),
    );
  }
}
