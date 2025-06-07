import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';
import 'package:mixologist_flutter/widgets/drink_progress_glass.dart';
import 'package:mixologist_flutter/widgets/connection_line.dart';
import 'package:mixologist_flutter/widgets/section_preview.dart';

void main() {
  group('Widget Integration Tests', () {
    
    testWidgets('DrinkProgressGlass displays correct progress', (tester) async {
      // Arrange
      const double testProgress = 0.6;
      const Color testColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DrinkProgressGlass(
              progress: testProgress,
              color: testColor,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DrinkProgressGlass), findsOneWidget);
      
      // Find the CustomPaint widget that renders the glass
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('DrinkProgressGlass handles progress bounds correctly', (tester) async {
      // Test cases for edge values
      final testCases = [
        0.0,    // Minimum
        0.5,    // Middle
        1.0,    // Maximum
        1.5,    // Over maximum (should be clamped)
        -0.1,   // Under minimum (should be clamped)
      ];

      for (final progress in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DrinkProgressGlass(
                progress: progress,
                color: Colors.red,
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

    testWidgets('ConnectionLine renders between points', (tester) async {
      // Arrange
      const startPoint = Offset(50, 50);
      const endPoint = Offset(150, 150);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: ConnectionLinePainter(
                startPoint: startPoint,
                endPoint: endPoint,
              ),
              size: const Size(200, 200),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('SectionPreview displays correct content', (tester) async {
      // Arrange
      const testTitle = "Test Section";
      const testDescription = "This is a test description";
      const testIcon = Icons.local_bar;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionPreview(
              title: testTitle,
              description: testDescription,
              icon: testIcon,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testDescription), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('SectionPreview handles tap events', (tester) async {
      // Arrange
      bool tapHandled = false;
      void onTapHandler() {
        tapHandled = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionPreview(
              title: "Tappable Section",
              description: "Tap me!",
              icon: Icons.touch_app,
              onTap: onTapHandler,
            ),
          ),
        ),
      );

      // Tap the section
      await tester.tap(find.byType(SectionPreview));
      await tester.pumpAndSettle();

      // Assert
      expect(tapHandled, isTrue);
    });

    testWidgets('Multiple MethodCards can be displayed together', (tester) async {
      // Arrange
      final methodCards = [
        const MethodCardData(
          stepNumber: 1,
          title: 'Muddle',
          description: 'Muddle mint leaves',
          imageAlt: 'Muddling',
          isCompleted: false,
          duration: '30s',
          difficulty: 'easy',
        ),
        const MethodCardData(
          stepNumber: 2,
          title: 'Shake',
          description: 'Shake with ice',
          imageAlt: 'Shaking',
          isCompleted: false,
          duration: '15s',
          difficulty: 'medium',
        ),
        const MethodCardData(
          stepNumber: 3,
          title: 'Strain',
          description: 'Strain into glass',
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

    testWidgets('MethodCard tip categories display correctly', (tester) async {
      // Test all tip categories
      final tipCategories = TipCategory.values;

      for (final category in tipCategories) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MethodCard(
                data: MethodCardData(
                  stepNumber: 1,
                  title: 'Test',
                  description: 'Testing tip category',
                  imageAlt: 'Test',
                  isCompleted: false,
                  duration: '10s',
                  difficulty: 'medium',
                  proTip: 'Test tip for ${category.label}',
                  tipCategory: category,
                ),
                initiallyExpanded: true, // Start expanded to see the tip
              ),
            ),
          ),
        );

        // Should find the category icon and label
        expect(find.byIcon(category.icon), findsOneWidget);
        expect(find.text(category.label), findsOneWidget);
        expect(find.text('Test tip for ${category.label}'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('DrinkProgressGlass with different colors renders correctly', (tester) async {
      // Test different colors
      final colors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
      ];

      for (final color in colors) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DrinkProgressGlass(
                progress: 0.7,
                color: color,
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

    testWidgets('ConnectionLine with different line styles', (tester) async {
      // Test different connection line configurations
      final testConfigurations = [
        {
          'start': const Offset(0, 0),
          'end': const Offset(100, 100),
          'color': Colors.black,
        },
        {
          'start': const Offset(50, 0),
          'end': const Offset(50, 200),
          'color': Colors.blue,
        },
        {
          'start': const Offset(0, 100),
          'end': const Offset(200, 100),
          'color': Colors.red,
        },
      ];

      for (final config in testConfigurations) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: ConnectionLinePainter(
                  startPoint: config['start'] as Offset,
                  endPoint: config['end'] as Offset,
                  color: config['color'] as Color,
                ),
                size: const Size(200, 200),
              ),
            ),
          ),
        );

        // Should render without errors
        expect(find.byType(CustomPaint), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('Complex widget hierarchy integration', (tester) async {
      // Test a complex hierarchy similar to what might be in the actual app
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Integration Test')),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Progress indicator at top
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DrinkProgressGlass(
                      progress: 0.4,
                      color: Colors.blue,
                    ),
                  ),
                  
                  // Section preview
                  SectionPreview(
                    title: "Current Step",
                    description: "Making your cocktail",
                    icon: Icons.local_bar,
                    onTap: () {},
                  ),
                  
                  // Method cards
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: MethodCard(
                      data: MethodCardData(
                        stepNumber: index + 1,
                        title: 'Step ${index + 1}',
                        description: 'Description for step ${index + 1}',
                        imageAlt: 'Step ${index + 1} image',
                        isCompleted: index == 0, // First step completed
                        duration: '${(index + 1) * 10}s',
                        difficulty: index == 0 ? 'easy' : 'medium',
                        proTip: index == 1 ? 'Pro tip for step 2' : null,
                        tipCategory: index == 1 ? TipCategory.technique : null,
                      ),
                      state: index == 0 
                          ? MethodCardState.completed 
                          : index == 1 
                              ? MethodCardState.active 
                              : MethodCardState.defaultState,
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert all components are present
      expect(find.byType(DrinkProgressGlass), findsOneWidget);
      expect(find.byType(SectionPreview), findsOneWidget);
      expect(find.byType(MethodCard), findsNWidgets(3));
      expect(find.text('Integration Test'), findsOneWidget);
      expect(find.text('Current Step'), findsOneWidget);
      expect(find.textContaining('Step 1'), findsOneWidget);
      expect(find.textContaining('Step 2'), findsOneWidget);
      expect(find.textContaining('Step 3'), findsOneWidget);
    });

    testWidgets('Theme switching integration', (tester) async {
      // Test widgets in both light and dark themes
      final themes = [
        ThemeData.light(),
        ThemeData.dark(),
      ];

      for (final theme in themes) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  DrinkProgressGlass(
                    progress: 0.5,
                    color: theme.primaryColor,
                  ),
                  SectionPreview(
                    title: "Theme Test",
                    description: "Testing ${theme.brightness.name} theme",
                    icon: Icons.palette,
                    onTap: () {},
                  ),
                  MethodCard(
                    data: const MethodCardData(
                      stepNumber: 1,
                      title: 'Theme Test Step',
                      description: 'Testing theme adaptation',
                      imageAlt: 'Theme test',
                      isCompleted: false,
                      duration: '30s',
                      difficulty: 'easy',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // All widgets should render correctly in both themes
        expect(find.byType(DrinkProgressGlass), findsOneWidget);
        expect(find.byType(SectionPreview), findsOneWidget);
        expect(find.byType(MethodCard), findsOneWidget);
        expect(find.text('Theme Test'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}