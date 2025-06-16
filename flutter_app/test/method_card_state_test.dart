import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/shared/widgets/method_card.dart';

void main() {
  testWidgets('MethodCard displays basic content', (tester) async {
    const data = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake well',
      imageUrl: 'https://example.com/image.png',
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

    // Verify basic content is displayed
    expect(find.text('Shake well'), findsOneWidget);
  });
}
