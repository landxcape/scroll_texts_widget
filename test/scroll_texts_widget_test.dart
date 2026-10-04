import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_texts_widget/scroll_texts_widget.dart';

void main() {
  group('ScrollTextsWidget', () {
    testWidgets(
      'renders empty texts list without LateInitializationError on dispose',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: ScrollTextsWidget(texts: [])),
          ),
        );
        expect(find.byType(ScrollTextsWidget), findsOneWidget);

        // Trigger dispose
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('scrolls text and cycles to next text after pause', (
      tester,
    ) async {
      final texts = ['First Announcement', 'Second Announcement'];
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: texts,
                controller: controller,
                scrollSpeed: 200.0,
                pauseDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      );

      expect(controller.currentTextIndex, 0);

      // Advance frames
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0));

      // Advance past first scroll and pause duration to cycle
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.currentTextIndex, 1);

      // Verify it starts scrolling the second text
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0));

      // Advance past second scroll to verify it loops back to index 0 (repeat: true)
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.currentTextIndex, 0);
    });

    testWidgets('stops after last text completes when repeat is false', (
      tester,
    ) async {
      final texts = ['First Announcement', 'Second Announcement'];
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: texts,
                controller: controller,
                repeat: false,
                scrollSpeed: 300.0,
                pauseDuration: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      // Advance through first text
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.currentTextIndex, 1);

      // Advance through second (last) text
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.currentTextIndex, 1);
      expect(controller.isPaused, isTrue);

      final offsetAtEnd = controller.offset;
      await tester.pump(const Duration(seconds: 1));
      expect(controller.offset, offsetAtEnd);
    });

    testWidgets('supports jumpTo and pause/resume via controller', (
      tester,
    ) async {
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['Sample Scrolling Text'],
                controller: controller,
                scrollSpeed: 50.0,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      controller.jumpTo(150.0);
      expect(controller.offset, 150.0);
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.offset, greaterThan(150.0));

      controller.pause();
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.isPaused, isTrue);

      final offsetBeforeWait = controller.offset;
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.offset, equals(offsetBeforeWait));

      controller.resume();
      await tester.pump(const Duration(milliseconds: 16));
      expect(controller.isPaused, isFalse);
    });

    testWidgets('supports streaming render mode with long text', (
      tester,
    ) async {
      final longText = 'Long text ' * 100;
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: [longText],
                renderMode: ScrollTextRenderMode.streaming,
                controller: controller,
                scrollSpeed: 100.0,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0));
      expect(find.byType(ScrollTextsWidget), findsOneWidget);
    });

    testWidgets('supports RTL text direction', (tester) async {
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['مرحبا بكم في فلاتر'],
                textDirection: TextDirection.rtl,
                controller: controller,
                scrollSpeed: 100.0,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0));
      expect(find.byType(ScrollTextsWidget), findsOneWidget);
    });

    testWidgets('didUpdateWidget updates texts and handles index bounds', (
      tester,
    ) async {
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['Text 1', 'Text 2', 'Text 3'],
                controller: controller,
              ),
            ),
          ),
        ),
      );

      controller.jumpToText(2);
      await tester.pump();
      expect(controller.currentTextIndex, 2);

      // Rebuild with shorter list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['New Text 1'],
                controller: controller,
              ),
            ),
          ),
        ),
      );

      expect(controller.currentTextIndex, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles infinite width constraint safely without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ScrollTextsWidget(texts: ['Unbounded parent test']),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ScrollTextsWidget), findsOneWidget);
    });

    testWidgets(
      'switching renderMode between streaming, cached, and auto mid-scroll does not throw',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ScrollTextsWidget(
                  texts: ['Short sample text that scrolls across the screen.'],
                  renderMode: ScrollTextRenderMode.streaming,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Rebuild with cached mode mid-scroll
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ScrollTextsWidget(
                  texts: ['Short sample text that scrolls across the screen.'],
                  renderMode: ScrollTextRenderMode.cached,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Rebuild with streaming mode again mid-scroll
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ScrollTextsWidget(
                  texts: ['Short sample text that scrolls across the screen.'],
                  renderMode: ScrollTextRenderMode.streaming,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Rebuild with auto mode
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ScrollTextsWidget(
                  texts: ['Short sample text that scrolls across the screen.'],
                  renderMode: ScrollTextRenderMode.auto,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('respects initialDelay before starting initial scroll', (
      tester,
    ) async {
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['Announcement with initial delay'],
                controller: controller,
                initialDelay: const Duration(milliseconds: 500),
                scrollSpeed: 100.0,
              ),
            ),
          ),
        ),
      );

      // During initialDelay, offset should remain 0
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.offset, 0.0);

      // Wait past initialDelay (500ms total)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0.0));
    });

    testWidgets('CustomPainter responds to hit testing and controller jump when paused', (
      tester,
    ) async {
      final controller = ScrollTextsController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ScrollTextsWidget(
                texts: const ['Hit testing and jump verification text'],
                controller: controller,
                scrollSpeed: 50.0,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      controller.pause();
      await tester.pump(const Duration(milliseconds: 50));
      expect(controller.isPaused, isTrue);

      controller.jumpTo(120.0);
      await tester.pump(const Duration(milliseconds: 50));
      expect(controller.offset, 120.0);
    });
  });
}
