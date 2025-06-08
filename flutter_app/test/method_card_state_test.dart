import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';

void main() {
  testWidgets('MethodCard expands on tap', (tester) async {
    const data = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake well',
      imageUrl: 'https://example.com/shake.jpg',
      imageAlt: 'alt',
      isCompleted: false,
      duration: '10s',
      difficulty: 'easy',
      proTip: 'Use a Boston shaker for best results',
      tipCategory: TipCategory.technique,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MethodCard(data: data),
      ),
    );

    // Description should always be visible
    expect(find.text('Shake well'), findsOneWidget);
    
    // Initially, the expand button should show "down" arrow (collapsed state)
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    
    // Tap the expand button to show pro tip
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();
    
    // After expansion, the button should show "up" arrow (expanded state)
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
  });
}
