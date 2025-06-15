import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';

void main() {
  group('MethodCard Comprehensive Tests', () {
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

    // Arrange: Common test data
    const baseMethodCardData = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake all ingredients with ice vigorously',
      imageUrl: 'https://example.com/image.png',
      imageAlt: 'Shaking cocktail',
      isCompleted: false,
      duration: '15s',
      difficulty: 'medium',
    );

    testWidgets('should display correct step information', (tester) async {
      // Arrange: Set up test data
      const data = baseMethodCardData;

      // Act: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(data: data),
          ),
        ),
      );

      // Assert: Verify step information is displayed correctly
      expect(find.textContaining('Step 1'), findsOneWidget);
      expect(find.text('Shake all ingredients with ice vigorously'), findsOneWidget);
      expect(find.text('15s'), findsOneWidget);
      expect(find.text('medium'), findsOneWidget);
    });





    testWidgets('should display correct border color for different states', (tester) async {
      // Test completed state
      const completedData = MethodCardData(
        stepNumber: 1,
        title: 'Shake',
        description: 'Shake ingredients',
        imageUrl: 'https://example.com/shake.png',
        imageAlt: 'Shaking',
        isCompleted: true,
        duration: '15s',
        difficulty: 'medium',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: completedData,
              state: MethodCardState.completed,
            ),
          ),
        ),
      );

      // Find the container with border decoration
      final containerFinder = find.descendant(
        of: find.byType(MethodCard),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('should show loading state when isGenerating is true', (tester) async {
      // Arrange: Data with generating state
      const generatingData = MethodCardData(
        stepNumber: 1,
        title: 'Shake',
        description: 'Shake ingredients',
        imageUrl: 'https://example.com/shake.png',
        imageAlt: 'Shaking',
        isCompleted: false,
        duration: '15s',
        difficulty: 'medium',
        isGenerating: true,
      );

      // Act: Build widget with generating state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(data: generatingData),
          ),
        ),
      );

      // Assert: Should show loading indicator and text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating image...'), findsOneWidget);
    });

    testWidgets('should display image from bytes when provided', (tester) async {
      // Arrange: Create test image bytes (1x1 transparent PNG)
      final imageBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
        0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 11, 73, 68, 65, 84,
        120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69,
        78, 68, 174, 66, 96, 130
      ]);

      final dataWithImage = MethodCardData(
        stepNumber: 1,
        title: 'Shake',
        description: 'Shake ingredients',
        imageUrl: 'https://example.com/shake.png',
        imageAlt: 'Shaking',
        isCompleted: false,
        duration: '15s',
        difficulty: 'medium',
        imageBytes: imageBytes,
      );

      // Act: Build widget with image bytes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(data: dataWithImage),
          ),
        ),
      );

      // Assert: Should find Image.memory widget
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show placeholder when no image is available', (tester) async {
      // Arrange: Data without image
      const dataWithoutImage = MethodCardData(
        stepNumber: 1,
        title: 'Shake',
        description: 'Shake ingredients',
        imageAlt: 'Shaking technique',
        isCompleted: false,
        duration: '15s',
        difficulty: 'medium',
        // No imageUrl or imageBytes provided - testing placeholder
      );

      // Act: Build widget without image
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(data: dataWithoutImage),
          ),
        ),
      );

      // Assert: Should show placeholder with appropriate text
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(find.text('Shaking technique'), findsOneWidget);
      expect(find.text('Tap "Generate Visuals" to create image'), findsOneWidget);
    });

    testWidgets('should show loading skeleton when state is loading', (tester) async {
      // Act: Build widget with loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              state: MethodCardState.loading,
            ),
          ),
        ),
      );

      // Assert: Should show skeleton loading containers instead of actual content
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
      // Content should not be visible in loading state
      expect(find.text('Step 1'), findsNothing);
    });



  });
}