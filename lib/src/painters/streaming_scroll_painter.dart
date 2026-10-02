import 'package:flutter/material.dart';

/// Represents a measured text chunk positioned at a specific horizontal offset.
class PositionedChunk {
  final TextPainter painter;
  final double x;

  const PositionedChunk({required this.painter, required this.x});
}

/// Painter that renders only the tokens currently positioned within the visible window.
class StreamingScrollPainter extends CustomPainter {
  final List<PositionedChunk> visibleChunks;
  final double containerWidth;

  StreamingScrollPainter({
    super.repaint,
    required this.visibleChunks,
    required this.containerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final chunk in visibleChunks) {
      final double textDrawY = (size.height - chunk.painter.height) / 2;
      chunk.painter.paint(canvas, Offset(chunk.x, textDrawY));
    }
  }

  @override
  bool shouldRepaint(covariant StreamingScrollPainter oldDelegate) {
    return true;
  }
}
