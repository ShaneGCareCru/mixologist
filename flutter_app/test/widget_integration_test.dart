import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/shared/widgets/method_card.dart';
import 'package:mixologist_flutter/shared/widgets/drink_progress_glass.dart';
import 'package:mixologist_flutter/shared/widgets/connection_line.dart';
import 'package:mixologist_flutter/shared/widgets/section_preview.dart';

void main() {
  group('Widget Integration Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    setUpAll(() {
      // Mock vibration platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('vibration'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'hasVibrator':
              return true;
            case 'vibrate':
              return null;
            default:
              throw PlatformException(
                code: 'Unimplemented',
                details: 'The vibration plugin does not implement ${methodCall.method}',
              );
          }
        },
      );
    });

    tearDownAll(() {
      // Clean up platform channel mocks
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('vibration'), null);
    });
    
    testWidgets('DrinkProgressGlass displays correct progress', (tester) async {
      // Arrange
      const DrinkProgress testProgress = DrinkProgress.mixed;
      const List<Color> testColors = [Colors.blue, Colors.green];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkProgressGlass(
              progress: testProgress,
              liquidColors: testColors,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DrinkProgressGlass), findsOneWidget);
      
      // Find the CustomPaint widget that renders the glass
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('DrinkProgressGlass handles all progress states correctly', (tester) async {
      // Test cases for all enum values
      final progressValues = [
        DrinkProgress.emptyGlass,
        DrinkProgress.ingredientsAdded,
        DrinkProgress.mixed,
        DrinkProgress.garnished,
        DrinkProgress.complete,
      ];

      for (final progress in progressValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DrinkProgressGlass(
                progress: progress,
                liquidColors: const [Colors.red, Colors.orange],
              ),
            ),
          ),
        );

        // Should not throw any errors and should render
        expect(find.byType(DrinkProgressGlass), findsOneWidget);
        
        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });


    testWidgets('SectionPreview displays correct content', (tester) async {
      // Arrange
      const testTitle = "Test Section";
      const testIcon = Icons.local_bar;
      const previewWidget = Text("Preview content");
      const expandedWidget = Text("Expanded content");

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionPreview(
              title: testTitle,
              icon: testIcon,
              previewContent: previewWidget,
              expandedContent: expandedWidget,
              totalItems: 5,
              expanded: false,
              onOpen: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text("Preview content"), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });


    testWidgets('Multiple MethodCards can be displayed together', (tester) async {
      // Arrange
      final methodCards = [
        const MethodCardData(
          stepNumber: 1,
          title: 'Muddle',
          description: 'Muddle mint leaves',
          imageUrl: 'https://example.com/muddle.png',
          imageAlt: 'Muddling',
          isCompleted: false,
          duration: '30s',
          difficulty: 'easy',
        ),
        const MethodCardData(
          stepNumber: 2,
          title: 'Shake',
          description: 'Shake with ice',
          imageUrl: 'https://example.com/shake.png',
          imageAlt: 'Shaking',
          isCompleted: false,
          duration: '15s',
          difficulty: 'medium',
        ),
        const MethodCardData(
          stepNumber: 3,
          title: 'Strain',
          description: 'Strain into glass',
          imageUrl: 'https://example.com/strain.png',
          imageAlt: 'Straining',
          isCompleted: false,
          duration: '5s',
          difficulty: 'easy',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: methodCards
                    .map((data) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MethodCard(data: data),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MethodCard), findsNWidgets(3));
      expect(find.textContaining('Step 1'), findsOneWidget);
      expect(find.textContaining('Step 2'), findsOneWidget);
      expect(find.textContaining('Step 3'), findsOneWidget);
      expect(find.text('Muddle mint leaves'), findsOneWidget);
      expect(find.text('Shake with ice'), findsOneWidget);
      expect(find.text('Strain into glass'), findsOneWidget);
    });

    testWidgets('MethodCard with different states display correctly', (tester) async {
      // Test different MethodCard states
      final states = [
        MethodCardState.defaultState,
        MethodCardState.active,
        MethodCardState.completed,
        MethodCardState.loading,
      ];

      for (int i = 0; i < states.length; i++) {
        final state = states[i];
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MethodCard(
                data: MethodCardData(
                  stepNumber: i + 1,
                  title: 'Test Step ${i + 1}',
                  description: 'Testing state: ${state.toString()}',
                  imageUrl: 'https://example.com/test.png',
                  imageAlt: 'Test',
                  isCompleted: state == MethodCardState.completed,
                  duration: '10s',
                  difficulty: 'medium',
                ),
                state: state,
              ),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(MethodCard), findsOneWidget);
        
        if (state != MethodCardState.loading) {
          // For non-loading states, content should be visible
          expect(find.textContaining('Step ${i + 1}'), findsOneWidget);
        }

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });


    testWidgets('DrinkProgressGlass with different colors renders correctly', (tester) async {
      // Test different color combinations
      final colorCombinations = [
        [Colors.red, Colors.pink],
        [Colors.green, Colors.teal],
        [Colors.blue, Colors.cyan],
        [Colors.orange, Colors.amber],
        [Colors.purple, Colors.indigo],
      ];

      for (final colors in colorCombinations) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DrinkProgressGlass(
                progress: DrinkProgress.garnished,
                liquidColors: colors,
              ),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(DrinkProgressGlass), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });



  });
}