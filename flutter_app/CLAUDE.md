# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Mixologist is a cross-platform Flutter app that serves as an AI-powered cocktail discovery and inventory management system. The app features an iOS-focused Cupertino design with natural language cocktail search, voice-enabled AI assistant, and visual inventory management.

## Critical Architecture Note

**The project maintains two parallel widget systems:**
- **Active Production**: `RecipeScreen` with legacy widgets (fully integrated with backend)
- **Design Philosophy**: `ImprovedRecipeScreen` with enhanced widgets (implements design philosophy but not actively used)

When working on recipes/UI, determine which system you're targeting. The improved system demonstrates better architectural patterns but requires integration work to become active.

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device/emulator
flutter run -d <device_id>

# List available devices and emulators
flutter devices
flutter emulators

# Launch iOS simulator
flutter emulators --launch apple_ios_simulator

# Build for production
flutter build ios
flutter build android
flutter build web
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run specific test by name
flutter test test/widgets/improved_components_test.dart --name "handles checkbox interaction"

# Run integration tests (requires backend server running)
flutter test integration_test/

# Run tests with coverage
flutter test --coverage

# Clean and rebuild (helpful when tests fail unexpectedly)
flutter clean && flutter pub get
```

### Backend Integration
The app communicates with a FastAPI backend server that must be running on localhost:8081 for full functionality.

## Architecture

### App Structure
- **Entry Point**: `lib/main.dart` → `lib/app.dart` (MixologistApp root widget)
- **Theme System**: iOS-focused Cupertino design in `lib/theme/`
- **Feature Modules**: Organized in `lib/features/` (auth, home, inventory, ai_assistant)
- **Shared Components**: Reusable widgets in `lib/shared/` and `lib/widgets/`
- **Design Philosophy Components**: Enhanced widgets in `lib/widgets/` (improved_*, safe_*, mixologist_*)

### Key Features

#### 1. Cocktail Discovery (`lib/features/home/`)
- Natural language search with fuzzy matching
- AI-powered recipe generation via backend API
- Visual recipe display with ingredient lists and methods

#### 2. AI Assistant (`lib/features/ai_assistant/`)
- Voice-enabled bartender using OpenAI Realtime API
- WebSocket communication for real-time interaction
- Rive animations for visual feedback

#### 3. Inventory Management (`lib/features/inventory/`)
- Visual shelf and list views of ingredients
- Camera-based ingredient recognition
- Quantity tracking and categorization

#### 4. Authentication (`lib/features/auth/`)
- Firebase Authentication integration
- Cross-platform configuration

### Data Models (`lib/models/`)
- **InventoryItem**: Core inventory data structure with category, quantity, image URL
- **Categories**: Spirits, Liqueurs, Mixers, Garnishes, Tools, Glassware

### Services (`lib/services/`)
- **AI Assistant Service**: Manages WebSocket connections to OpenAI Realtime API
- **Inventory Service**: Handles CRUD operations for inventory items
- **Backend API**: HTTP client for FastAPI integration on port 8081

### Widget Systems

#### Legacy Widgets (`lib/shared/widgets/`)
- **Recipe Display**: `method_card.dart` (actively used)
- **UI utilities**: `loading_screen.dart`, `connection_line.dart`, `lazy_load_section.dart`
- **Inventory**: `inventory_shelf.dart`, `bottle_card.dart`, `inventory_item_card.dart`

#### Design Philosophy Widgets (`lib/widgets/`)
- **Safe Rendering**: `safe_recipe_renderer.dart` (graceful data handling)
- **Unified Images**: `mixologist_image.dart` (enforced aspect ratios)
- **Enhanced Cards**: `improved_method_card.dart` (haptic feedback, accessibility)
- **Recipe Screen**: `improved_recipe_screen.dart` (Material Design + philosophy colors)

## Backend API Integration

### Key Endpoints
- `POST /generate_recipe`: Natural language recipe generation
- `POST /identify_ingredient`: Camera-based ingredient recognition
- `GET /inventory`: Retrieve inventory items
- `POST /inventory`: Add new inventory items

### API Communication
- Uses `http` package for REST API calls
- Base URL: `http://localhost:8081`
- Backend server must be running for full app functionality

## Firebase Configuration

### Platforms Configured
- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`
- macOS: `macos/Runner/GoogleService-Info.plist`

### Firebase Services
- Authentication
- Firestore (configured but not actively used in current implementation)

## Testing Strategy

### Test Organization
- **Unit Tests**: `test/api/`, `test/features/`
- **Widget Tests**: `test/screens/`, individual widget test files
- **Integration Tests**: `test/integration/`, `integration_test/`

### Backend Integration Tests
- Require the FastAPI backend server to be running
- Test real API communication and data flow
- Located in `test/api/backend_api_test.dart`

## Theme System

### Color Palette (`lib/theme/app_colors.dart`)
Cocktail-inspired colors including whiskey amber, gin green, vodka clear, and dark background tones.

### Design Philosophy (`docs/design_philosophy.md`)
- iOS-first Apple Human Interface Guidelines
- **Colors**: Amber (#B8860B), Sage (#87A96B), Cream (#F5F5DC), Charcoal (#36454F)
- **Image System**: 16:9 hero, 1:1 ingredients/equipment, 4:3 method steps
- **Safe Data Handling**: Graceful fallbacks for missing/null data
- **Unified Visual Language**: SF Symbols, Core Haptics, Dynamic Type

## Development Workflow

### Prerequisites
1. Flutter SDK (>=2.19.0 <3.0.0)
2. Firebase CLI for Firebase configuration
3. FastAPI backend server running on localhost:8081

### Common Development Tasks

#### Adding New Features
1. Create feature folder in `lib/features/`
2. Implement feature-specific widgets, services, and models
3. Update routing in `lib/app.dart`
4. Add corresponding tests

#### Backend Integration
1. Define API endpoints in service layer
2. Create data models for request/response
3. Implement error handling and loading states
4. Add integration tests

#### UI Components
1. Follow Cupertino design patterns
2. Use existing theme colors and text styles
3. Implement responsive design for multiple screen sizes
4. Add accessibility support

### Known Limitations
- OpenAI API key is placeholder ("your-openai-api-key-here")
- Some features disabled due to API limitations
- Backend server dependency for full functionality

## Current Development Status

### Widget Architecture State
- **Production**: Uses legacy `RecipeScreen` with full backend integration
- **Enhanced**: `ImprovedRecipeScreen` implements design philosophy but requires routing updates to become active
- **Navigation**: Currently routes to legacy system in `home_screen.dart`

### Implementation Patterns

#### Safe Data Handling (Design Philosophy)
```dart
// Use SafeRecipeRenderer for null-safe data access
SafeRecipeRenderer(
  recipeData: widget.recipeData,
  builder: (context, safeData) => YourWidget(safeData),
)
```

#### Unified Image System (Design Philosophy)
```dart
// Enforces aspect ratios and consistent caching
MixologistImage.recipeHero(altText: 'Cocktail presentation'),
MixologistImage.ingredient(altText: 'Whiskey'),
MixologistImage.methodStep(altText: 'Shaking technique'),
MixologistImage.equipment(altText: 'Cocktail shaker'),
```

#### Testing Patterns
- Platform channel mocking for vibration/haptics
- Comprehensive widget state testing
- Image bytes testing with actual PNG data
- Error state validation and loading skeleton testing

### Key Files to Understand
- `docs/design_philosophy.md` - Complete design system documentation
- `lib/widgets/safe_recipe_renderer.dart` - Null-safe data wrapper pattern
- `lib/widgets/mixologist_image.dart` - Unified image aspect ratio system
- `test/widgets/improved_components_test.dart` - Modern testing patterns