import 'package:flutter/material.dart';
import '../scroll_controller.dart';

/// Highly efficient painter that reuses a pre-laid-out [TextPainter].
///
/// Calling paint() performs zero layout operations, ensuring 60/120fps performance.
class CachedScrollPainter extends CustomPainter {
  final TextPainter textPainter;
  final ScrollTextsController? controller;
  final double? scrollOffset;
  final double containerWidth;
  final TextDirection textDirection;

  CachedScrollPainter({
    super.repaint,
    required this.textPainter,
    this.controller,
    this.scrollOffset,
    required this.containerWidth,
    required this.textDirection,
  });

  double get _currentOffset => controller?.offset ?? scrollOffset ?? 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double offset = _currentOffset;
    final double textDrawX;
    if (textDirection == TextDirection.ltr) {
      textDrawX = containerWidth - offset;
    } else {
      textDrawX = -textPainter.width + offset;
    }

    final double textDrawY = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textDrawX, textDrawY));
  }

  @override
  bool shouldRepaint(covariant CachedScrollPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.controller != controller ||
        oldDelegate.containerWidth != containerWidth ||
        oldDelegate.textPainter != textPainter ||
        oldDelegate.textDirection != textDirection;
  }
}
