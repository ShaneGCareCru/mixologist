import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/features/home/screens/home_screen.dart';
import 'package:mixologist_flutter/features/recipe/screens/recipe_screen.dart';

void main() {
  testWidgets('should handle empty search input gracefully', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Try to submit empty search
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Should remain on HomeScreen (no navigation)
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(RecipeScreen), findsNothing);
    // Should not show loading screen
    expect(find.text('Generating your recipe...'), findsNothing);
  });
}
