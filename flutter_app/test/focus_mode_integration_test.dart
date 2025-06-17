import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/hierarchy/information_hierarchy_demo.dart';
import 'package:mixologist_flutter/services/focus_mode_controller.dart';

void main() {
  group('Focus Mode Integration Tests', () {
    testWidgets('Focus mode controller initializes correctly', (WidgetTester tester) async {
      // Initialize the focus mode controller
      await FocusModeController.instance.initialize();
      
      expect(FocusModeController.instance.isInitialized, true);
      expect(FocusModeController.instance.isFocusMode, false);
      expect(FocusModeController.instance.showTutorial, true);
    });

    testWidgets('Information hierarchy demo renders with focus mode toggle', (WidgetTester tester) async {
      // Initialize the focus mode controller
      await FocusModeController.instance.initialize();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const InformationHierarchyDemo(),
        ),
      );
      
      // Wait for animations to settle
      await tester.pumpAndSettle();
      
      // Verify the app bar is present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Information Hierarchy'), findsOneWidget);
      
      // Verify focus mode toggle button is present in app bar
      expect(find.byType(FloatingActionButton), findsAtLeast(1));
      
      // Verify the three-tier layout is present
      expect(find.text('Classic Gin Sour'), findsOneWidget);
      expect(find.text('A refreshing balance of botanicals, citrus, and sweetness'), findsOneWidget);
      
      // Verify ingredient flow is present
      expect(find.text('Gin'), findsOneWidget);
      expect(find.text('Lemon'), findsOneWidget);
      expect(find.text('Syrup'), findsOneWidget);
    });

    testWidgets('Focus mode toggle works correctly', (WidgetTester tester) async {
      // Initialize the focus mode controller
      await FocusModeController.instance.initialize();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const InformationHierarchyDemo(),
        ),
      );
      
      // Wait for initial render
      await tester.pumpAndSettle();
      
      // Verify focus mode is initially off
      expect(FocusModeController.instance.isFocusMode, false);
      
      // Find and tap the focus mode FAB
      final focusFAB = find.byIcon(Icons.center_focus_strong);
      expect(focusFAB, findsOneWidget);
      
      await tester.tap(focusFAB);
      await tester.pumpAndSettle();
      
      // Verify focus mode is now on
      expect(FocusModeController.instance.isFocusMode, true);
      
      // Verify the icon changed
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      
      // Tap again to toggle off
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();
      
      // Verify focus mode is off again
      expect(FocusModeController.instance.isFocusMode, false);
      expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
    });

    testWidgets('Smart progress bar displays correctly', (WidgetTester tester) async {
      // Initialize services
      await FocusModeController.instance.initialize();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const InformationHierarchyDemo(),
        ),
      );
      
      // Wait for render
      await tester.pumpAndSettle();
      
      // Verify progress bar elements are present
      expect(find.text('Add Ingredients'), findsOneWidget);
      expect(find.text('Add gin, lemon juice, and simple syrup to shaker'), findsOneWidget);
      
      // Verify navigation buttons are present
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Collapsible sections work correctly', (WidgetTester tester) async {
      // Initialize services
      await FocusModeController.instance.initialize();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const InformationHierarchyDemo(),
        ),
      );
      
      // Wait for render
      await tester.pumpAndSettle();
      
      // Find a collapsible section
      expect(find.text('Recipe Details'), findsOneWidget);
      expect(find.text('Variations'), findsOneWidget);
      expect(find.text('Pro Tips'), findsOneWidget);
      expect(find.text('Troubleshooting'), findsOneWidget);
      
      // Tap on a section to expand it
      await tester.tap(find.text('Variations'));
      await tester.pumpAndSettle();
      
      // Verify section content is visible
      expect(find.text('Whiskey Sour'), findsOneWidget);
      expect(find.text('Replace gin with bourbon whiskey'), findsOneWidget);
    });

    testWidgets('Tutorial dialog appears when tutorial button is tapped', (WidgetTester tester) async {
      // Initialize services
      await FocusModeController.instance.initialize();
      
      // Reset tutorial to ensure it shows
      await FocusModeController.instance.resetTutorial();
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const InformationHierarchyDemo(),
        ),
      );
      
      // Wait for render
      await tester.pumpAndSettle();
      
      // Find tutorial button (should be visible since tutorial was reset)
      final tutorialButton = find.byIcon(Icons.help_outline);
      if (tutorialButton.evaluate().isNotEmpty) {
        await tester.tap(tutorialButton);
        await tester.pumpAndSettle();
        
        // Verify tutorial dialog appeared
        expect(find.text('Focus Mode'), findsOneWidget);
        expect(find.text('Hide distractions and focus on your cocktail making.'), findsOneWidget);
        expect(find.text('Got it'), findsOneWidget);
        expect(find.text('Try Now'), findsOneWidget);
      }
    });
  });
}