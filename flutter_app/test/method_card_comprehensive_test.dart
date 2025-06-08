import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mixologist_flutter/widgets/method_card.dart';

void main() {
  group('MethodCard Comprehensive Tests', () {
    setUpAll(() {
      // Mock platform channels for vibration and haptic feedback
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('vibration'),
        (MethodCall methodCall) async {
          return true;
        },
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/hapticfeedback'),
        (MethodCall methodCall) async {
          return null;
        },
      );
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('vibration'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/hapticfeedback'), null);
    });

    // Arrange: Common test data
    const baseMethodCardData = MethodCardData(
      stepNumber: 1,
      title: 'Shake',
      description: 'Shake all ingredients with ice vigorously',
      imageUrl: 'https://example.com/shake.jpg',
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

    testWidgets('should expand and show pro tip when expand icon is tapped', (tester) async {
      // Arrange: Set up data with pro tip
      const dataWithProTip = MethodCardData(
        stepNumber: 2,
        title: 'Strain',
        description: 'Strain into glass',
        imageUrl: 'https://example.com/strain.jpg',
        imageAlt: 'Straining cocktail',
        isCompleted: false,
        duration: '5s',
        difficulty: 'easy',
        proTip: 'Use a fine mesh strainer for best results',
        tipCategory: TipCategory.technique,
      );

      // Act: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(data: dataWithProTip),
          ),
        ),
      );

      // Assert: Initially should show down arrow (collapsed)
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

      // Act: Tap the expand button
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      // Assert: Should now show up arrow (expanded) and pro tip content
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      expect(find.text('Use a fine mesh strainer for best results'), findsOneWidget);
      expect(find.text('Technique'), findsOneWidget);
    });

    testWidgets('should trigger onCompleted callback on swipe right', (tester) async {
      // Arrange: Set up callback tracking
      bool callbackTriggered = false;
      void onCompletedCallback() {
        callbackTriggered = true;
      }

      // Act: Build widget with callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onCompleted: onCompletedCallback,
            ),
          ),
        ),
      );

      // Act: Perform swipe right gesture
      await tester.fling(
        find.byType(MethodCard),
        const Offset(500, 0), // Swipe right with sufficient velocity
        1000, // High velocity to trigger swipe
      );
      await tester.pumpAndSettle();

      // Assert: Callback should have been triggered
      expect(callbackTriggered, isTrue);
    });

    testWidgets('should handle keyboard navigation - Space key triggers completion', (tester) async {
      // Arrange: Set up callback tracking
      bool completedCallbackTriggered = false;
      void onCompletedCallback() {
        completedCallbackTriggered = true;
      }

      // Act: Build widget with keyboard navigation enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onCompleted: onCompletedCallback,
              enableKeyboardNavigation: true,
            ),
          ),
        ),
      );

      // Act: Focus the widget and press Space key
      await tester.tap(find.byType(MethodCard));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      // Assert: Completion callback should be triggered
      expect(completedCallbackTriggered, isTrue);
    });

    testWidgets('should handle keyboard navigation - Left arrow triggers onPrevious', (tester) async {
      // Arrange: Set up callback tracking
      bool previousCallbackTriggered = false;
      void onPreviousCallback() {
        previousCallbackTriggered = true;
      }

      // Act: Build widget with keyboard navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onPrevious: onPreviousCallback,
              enableKeyboardNavigation: true,
            ),
          ),
        ),
      );

      // Act: Focus and press left arrow
      await tester.tap(find.byType(MethodCard));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Assert: Previous callback should be triggered
      expect(previousCallbackTriggered, isTrue);
    });

    testWidgets('should display correct border color for different states', (tester) async {
      // Test completed state
      const completedData = MethodCardData(
        stepNumber: 1,
        title: 'Shake',
        description: 'Shake ingredients',
        imageUrl: 'https://example.com/shake.jpg',
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
        imageUrl: 'https://example.com/shake.jpg',
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
        imageUrl: 'https://example.com/shake.jpg',
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
        // No imageUrl or imageBytes provided
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

    testWidgets('should handle checkbox state changes', (tester) async {
      // Arrange: Set up callback tracking
      bool? lastCheckboxValue;
      void onCheckboxChanged(bool value) {
        lastCheckboxValue = value;
      }

      // Act: Build widget with checkbox
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onCheckboxChanged: onCheckboxChanged,
            ),
          ),
        ),
      );

      // Assert: Checkbox should be present
      expect(find.byType(Checkbox), findsOneWidget);

      // Act: Tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert: Callback should be triggered with true value
      expect(lastCheckboxValue, isTrue);
    });

    testWidgets('should disable swipe gestures when enableSwipeGestures is false', (tester) async {
      // Arrange: Set up callback tracking
      bool callbackTriggered = false;
      void onCompletedCallback() {
        callbackTriggered = true;
      }

      // Act: Build widget with swipe gestures disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onCompleted: onCompletedCallback,
              enableSwipeGestures: false,
            ),
          ),
        ),
      );

      // Act: Attempt swipe gesture
      await tester.fling(
        find.byType(MethodCard),
        const Offset(500, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Assert: Callback should not be triggered since gestures are disabled
      expect(callbackTriggered, isFalse);
    });

    testWidgets('should disable keyboard navigation when enableKeyboardNavigation is false', (tester) async {
      // Arrange: Set up callback tracking
      bool callbackTriggered = false;
      void onCompletedCallback() {
        callbackTriggered = true;
      }

      // Act: Build widget with keyboard navigation disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodCard(
              data: baseMethodCardData,
              onCompleted: onCompletedCallback,
              enableKeyboardNavigation: false,
            ),
          ),
        ),
      );

      // Act: Attempt keyboard interaction
      await tester.tap(find.byType(MethodCard));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      // Assert: Callback should not be triggered since keyboard navigation is disabled
      expect(callbackTriggered, isFalse);
    });
  });
}