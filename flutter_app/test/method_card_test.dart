import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';

void main() {
  testWidgets('MethodCard displays title and description', (tester) async {
    const data = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake all ingredients with ice',
      imageUrl: 'https://example.com/image.png',
      imageAlt: 'alt',
      isCompleted: false,
      duration: '30s',
      difficulty: 'easy',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodCard(data: data),
        ),
      ),
    );

    expect(find.textContaining('Step 1'), findsOneWidget);
    expect(find.text('Shake all ingredients with ice'), findsOneWidget);
  });
}
