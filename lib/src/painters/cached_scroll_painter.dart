import 'package:flutter/material.dart';

/// Highly efficient painter that reuses a pre-laid-out [TextPainter].
///
/// Calling paint() performs zero layout operations, ensuring 60/120fps performance.
class CachedScrollPainter extends CustomPainter {
  final TextPainter textPainter;
  final double scrollOffset;
  final double containerWidth;
  final TextDirection textDirection;

  CachedScrollPainter({
    super.repaint,
    required this.textPainter,
    required this.scrollOffset,
    required this.containerWidth,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double textDrawX;
    if (textDirection == TextDirection.ltr) {
      textDrawX = containerWidth - scrollOffset;
    } else {
      textDrawX = -textPainter.width + scrollOffset;
    }

    final double textDrawY = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textDrawX, textDrawY));
  }

  @override
  bool shouldRepaint(covariant CachedScrollPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.containerWidth != containerWidth ||
        oldDelegate.textPainter != textPainter ||
        oldDelegate.textDirection != textDirection;
  }
}
