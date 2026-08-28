# Skillet 🍳

A small cross-platform recipe app built with **Flutter** (Dart). Browse recipes
by category, search by name, open a full recipe with ingredients and
step-by-step instructions, and save favorites that persist between sessions.

**Live demo:** https://pavneetgrewal021-hash.github.io/skillet/

Data comes from the free [TheMealDB](https://www.themealdb.com/api.php) REST API
(no API key required).

## Screenshots

> Run `flutter run -d chrome` and drop screenshots of the Browse, Recipe, and
> Saved screens in a `screenshots/` folder, then link them here.

| Browse | Recipe detail | Saved |
|---|---|---|
| _screenshot_ | _screenshot_ | _screenshot_ |

## Features

- **Browse** — grid of recipe categories → list of meals in a category
- **Search** — debounced free-text search by meal name
- **Recipe detail** — hero image, ingredient list with measures, instructions,
  links to the original source and a YouTube video
- **Favorites** — tap the heart anywhere; saved locally with `shared_preferences`
  and restored on next launch
- **Surprise me** — jump to a random recipe
- Light & dark theme (follows the system setting), Material 3
- Loading / error / empty states on every network call, with retry
- Pull-to-refresh

## Tech and concepts

| Area | Choice |
|---|---|
| State management | `provider` (`ChangeNotifier`) for the favorites store |
| Networking | `http`, wrapped in a typed `MealApi` client with its own exception type |
| Local persistence | `shared_preferences` (JSON-encoded list) |
| Images | `cached_network_image` |
| External links | `url_launcher` |
| Navigation | `Navigator` + `MaterialPageRoute`; `IndexedStack` tab shell |
| Tests | model parsing, an async-UI widget test, favorites toggle |
| CI/CD | GitHub Actions: analyze + test + build, deploy to GitHub Pages |

## Project layout

```
lib/
  main.dart                     app entry, theme wiring, provider setup
  theme.dart                    Material 3 light/dark themes from one seed color
  models/meal.dart              MealSummary, Meal, Ingredient, Category
  services/
    meal_api.dart               TheMealDB client
    favorites_provider.dart     saved-recipes store + disk persistence
  screens/
    home_shell.dart             bottom-nav frame
    categories_screen.dart      category grid + "surprise me"
    category_meals_screen.dart  meals within a category
    meal_detail_screen.dart     full recipe
    search_screen.dart          debounced search
    favorites_screen.dart       saved recipes
  widgets/
    async_view.dart             reusable loading/error/empty states
    meal_card.dart              list row with favorite toggle
```

## Run it locally

```bash
flutter pub get
flutter run -d chrome        # web
# or: flutter run             # any connected device / emulator
```

## Test

```bash
flutter analyze
flutter test
```

## What I learned

My first Flutter project. I picked up the widget tree and the `StatefulWidget`
lifecycle, `Future` / `FutureBuilder` for async UI, `provider` for app-wide
state, parsing JSON into model classes, local persistence, and Material 3
theming. The trickiest parts were debouncing the search field so it doesn't
fire a request per keystroke, and holding one `Future` per query in state
instead of recreating it on every rebuild.
