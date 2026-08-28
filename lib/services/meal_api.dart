import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Raised when a request fails or the response can't be used. The [message]
/// is safe to show directly to the user.
class MealApiException implements Exception {
  MealApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin client for TheMealDB's free JSON API.
///
/// Docs: https://www.themealdb.com/api.php
/// The "1" segment in the path is the public developer test key.
class MealApi {
  MealApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<Map<String, dynamic>> _getJson(String path) async {
    final uri = Uri.parse('$_base/$path');
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw MealApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw MealApiException(
        'Server error (${response.statusCode}). Please try again later.',
      );
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw MealApiException('Got an unexpected response from the server.');
    }
  }

  /// Every recipe category.
  Future<List<Category>> fetchCategories() async {
    final data = await _getJson('categories.php');
    final list = (data['categories'] as List?) ?? const [];
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Meal summaries within a category.
  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final data =
        await _getJson('filter.php?c=${Uri.encodeComponent(category)}');
    final list = (data['meals'] as List?) ?? const [];
    return list
        .map((e) => MealSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Full details for one meal, or null if the id no longer resolves.
  Future<Meal?> fetchMealById(String id) async {
    final data = await _getJson('lookup.php?i=${Uri.encodeComponent(id)}');
    final list = (data['meals'] as List?) ?? const [];
    if (list.isEmpty) return null;
    return Meal.fromJson(list.first as Map<String, dynamic>);
  }

  /// Free-text search by meal name. This endpoint returns full meal objects.
  Future<List<Meal>> searchMealsByName(String query) async {
    final data = await _getJson('search.php?s=${Uri.encodeComponent(query)}');
    final list = (data['meals'] as List?) ?? const [];
    return list.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// A single random meal, for the "Surprise me" button.
  Future<Meal> fetchRandomMeal() async {
    final data = await _getJson('random.php');
    final list = (data['meals'] as List?) ?? const [];
    if (list.isEmpty) {
      throw MealApiException('No meal came back. Try again.');
    }
    return Meal.fromJson(list.first as Map<String, dynamic>);
  }
}
