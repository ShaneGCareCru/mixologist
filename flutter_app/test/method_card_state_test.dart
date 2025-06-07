import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';

void main() {
  testWidgets('MethodCard expands on tap', (tester) async {
    const data = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake well',
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
    
    // Pro tip should be hidden initially
    expect(find.text('Use a Boston shaker for best results'), findsNothing);
    
    // Tap the expand button to show pro tip
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();
    
    // Pro tip should now be visible
    expect(find.text('Use a Boston shaker for best results'), findsOneWidget);
  });
}
