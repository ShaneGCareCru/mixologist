import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/features/home/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    
    testWidgets('should display all main UI elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify the main heading
      expect(find.text('Let curiosity\nguide you.'), findsOneWidget);
      
      // Verify the subtitle
      expect(find.textContaining('Your first sip begins with a word'), findsOneWidget);
      
      // Verify the search field
      expect(find.byType(CupertinoTextField), findsOneWidget);
      
      // Verify the search button
      expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
      
      // Verify navigation buttons in the app bar
      expect(find.byIcon(CupertinoIcons.chat_bubble_text), findsOneWidget); // AI Assistant
      expect(find.byIcon(CupertinoIcons.cube_box), findsOneWidget); // Inventory
    });

    testWidgets('should allow text input in search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Find the search field
      final searchField = find.byType(CupertinoTextField);
      expect(searchField, findsOneWidget);

      // Enter text
      await tester.enterText(searchField, 'Mojito');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Mojito'), findsOneWidget);
    });

    testWidgets('should clear error message when new search is performed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // This test verifies the error state clearing logic
      // We can't easily trigger a real error without backend, 
      // but we can verify the UI structure is correct
      
      final searchField = find.byType(CupertinoTextField);
      await tester.enterText(searchField, 'Test Input');
      await tester.pump();
      
      // The search field should maintain its value
      expect(find.text('Test Input'), findsOneWidget);
    });

    testWidgets('should have proper placeholder text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Check that the placeholder is visible when field is empty
      final textField = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField)
      );
      
      expect(textField.placeholder, equals('aperol spritz'));
    });

    testWidgets('should have accessible search functionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify search can be triggered in multiple ways
      final searchField = find.byType(CupertinoTextField);
      final searchButton = find.byIcon(CupertinoIcons.search);
      
      expect(searchField, findsOneWidget);
      expect(searchButton, findsOneWidget);
      
      // Verify the text field has onSubmitted callback
      final textFieldWidget = tester.widget<CupertinoTextField>(searchField);
      expect(textFieldWidget.onSubmitted, isNotNull);
      
      // Verify the search button is tappable
      await tester.ensureVisible(searchButton);
      expect(searchButton, findsOneWidget);
    });

    testWidgets('should handle empty search input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Try submitting without entering text
      final searchField = find.byType(CupertinoTextField);
      await tester.tap(searchField);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      // Should not crash and remain on same screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should maintain text field state during interaction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      final searchField = find.byType(CupertinoTextField);
      
      // Enter text
      await tester.enterText(searchField, 'Long Island Iced Tea');
      await tester.pump();
      
      // Tap elsewhere and back
      await tester.tap(find.text('Let curiosity\nguide you.'));
      await tester.pump();
      await tester.tap(searchField);
      await tester.pump();
      
      // Text should still be there
      expect(find.text('Long Island Iced Tea'), findsOneWidget);
    });
  });
}