import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/flow/widgets/liquid_drop.dart';

void main() {
  testWidgets('LiquidDrop renders with value and color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidDrop(value: 0.5, color: Colors.red),
        ),
      ),
    );
    expect(find.byType(LiquidDrop), findsOneWidget);
  });
}
