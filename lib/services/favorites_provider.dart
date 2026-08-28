import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

/// Holds the user's saved recipes and mirrors them to disk (via
/// shared_preferences) so they survive an app restart.
///
/// This is a [ChangeNotifier] — screens listen with `context.watch` and
/// rebuild whenever the saved set changes.
class FavoritesProvider extends ChangeNotifier {
  static const _storageKey = 'favorite_meals_v1';

  final Map<String, MealSummary> _byId = {};
  bool _loaded = false;

  /// False until [load] has finished reading from disk.
  bool get isLoaded => _loaded;

  List<MealSummary> get all => _byId.values.toList(growable: false);

  int get count => _byId.length;

  bool contains(String id) => _byId.containsKey(id);

  /// Read the saved list from disk. Call once at startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final summary = MealSummary(
          id: map['id'] as String,
          name: map['name'] as String,
          thumbnail: map['thumbnail'] as String,
        );
        _byId[summary.id] = summary;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Add the meal if it isn't saved, remove it if it is.
  Future<void> toggle(MealSummary meal) async {
    if (_byId.containsKey(meal.id)) {
      _byId.remove(meal.id);
    } else {
      _byId[meal.id] = meal;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _byId.values
        .map((m) => {
              'id': m.id,
              'name': m.name,
              'thumbnail': m.thumbnail,
            })
        .toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }
}
