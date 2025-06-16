# Flutter Modularization & Refactor Checklist

## Baseline Test Results
- [ ] Run `flutter test` before refactor and record results.

## Refactor Steps

### 1. Theme & Styles
- [] Create `lib/theme/` directory.
- [] Move all color, text style, icon, and constant definitions from `main.dart` and `ios_theme.dart` into:
  - [] `theme/app_colors.dart`
  - [] `theme/app_text_styles.dart`
  - [] `theme/app_icons.dart`
  - [] `theme/app_constants.dart`
- [] Refactor `ios_theme.dart` to only contain iOS-specific helpers.

### 2. App Entry & Routing
- [] Create `lib/app.dart` for app root, theme, and routing.
- [] Refactor `main.dart` to only call `runApp(const MixologistApp())`.
- [ ] Run `flutter test` before refactor and record results.

### 3. Feature Folders
- [ ] Create `features/auth/`, `features/home/`, `features/recipe/`, `features/inventory/`, `features/ai_assistant/`.
- [ ] Move each main screen/page to its feature folder.
- [ ] Move feature-specific widgets into `widgets/` subfolders.
- [ ] Move feature services and models as needed.
- [ ] Update all import statements to reflect new file locations.

- [ ] Run `flutter test` before refactor and record results.

### 4. Shared Components
- [ ] Create `shared/widgets/` and `shared/utils/`.
- [ ] Move reusable widgets (e.g., `GlassmorphicCard`, `ios_card.dart`, `ios_search_bar.dart`, `loading_screen.dart`, `connection_line.dart`) to `shared/widgets/`.
- [ ] Move utility functions to `shared/utils/`.
- [ ] Update all import statements to reflect new file locations.

- [ ] Run `flutter test` before refactor and record results.

### 5. Models
- [ ] Create `models/` for shared data models (e.g., `ingredient.dart`, `recipe.dart`, `equipment.dart`, `trivia_fact.dart`).
- [ ] Run `flutter test` before refactor and record results.

### 6. Services
- [ ] Move API, Firebase, and other service logic into `services/` subfolders within each feature, or `shared/services/` if used by multiple features.
- [ ] Run `flutter test` before refactor and record results.

### 7. Update Imports
- [ ] Update all import statements to reflect new file locations.
- [ ] Run `flutter test` before refactor and record results.

### 8. Test & Validate
- [ ] Run `flutter test` after refactor to ensure all tests pass or fail for the same reasons as before. 