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
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MethodCard(data: data),
      ),
    );

    expect(find.text('Shake well'), findsNothing);
    await tester.tap(find.byType(MethodCard));
    await tester.pumpAndSettle();
    expect(find.text('Shake well'), findsOneWidget);
  });
}
