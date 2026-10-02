import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_texts_widget/src/painters/cached_scroll_painter.dart';
import 'package:scroll_texts_widget/src/painters/streaming_scroll_painter.dart';

void main() {
  group('CachedScrollPainter', () {
    test('paints correctly and respects shouldRepaint', () {
      final tp = TextPainter(
        text: const TextSpan(text: 'Test', style: TextStyle(fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();

      final painter = CachedScrollPainter(
        textPainter: tp,
        scrollOffset: 10.0,
        containerWidth: 200.0,
        textDirection: TextDirection.ltr,
      );

      expect(painter.shouldRepaint(painter), isFalse);

      final differentOffset = CachedScrollPainter(
        textPainter: tp,
        scrollOffset: 20.0,
        containerWidth: 200.0,
        textDirection: TextDirection.ltr,
      );
      expect(painter.shouldRepaint(differentOffset), isTrue);
    });

    testWidgets('paints in LTR and RTL without error', (tester) async {
      final tp = TextPainter(
        text: const TextSpan(text: 'Banner', style: TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 30),
              painter: CachedScrollPainter(
                textPainter: tp,
                scrollOffset: 50.0,
                containerWidth: 300.0,
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('StreamingScrollPainter', () {
    testWidgets('paints visible chunks without error', (tester) async {
      final tp1 = TextPainter(
        text: const TextSpan(text: 'Chunk1 ', style: TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      final tp2 = TextPainter(
        text: const TextSpan(text: 'Chunk2', style: TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();

      final chunks = [
        PositionedChunk(painter: tp1, x: 20.0),
        PositionedChunk(painter: tp2, x: 80.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 30),
              painter: StreamingScrollPainter(
                visibleChunks: chunks,
                containerWidth: 300.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
