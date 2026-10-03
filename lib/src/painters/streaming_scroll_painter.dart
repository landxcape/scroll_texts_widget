import 'package:flutter/material.dart';
import '../scroll_controller.dart';

/// Represents an active token for streaming window painting.
class ActiveStreamingChunk {
  final TextPainter painter;
  final double width;
  final double startOffset;

  const ActiveStreamingChunk({
    required this.painter,
    required this.width,
    required this.startOffset,
  });
}

/// Represents a measured text chunk positioned at a specific horizontal offset.
class PositionedChunk {
  final TextPainter painter;
  final double x;

  const PositionedChunk({required this.painter, required this.x});
}

/// Painter that renders only the tokens currently positioned within the visible window.
class StreamingScrollPainter extends CustomPainter {
  final ScrollTextsController? controller;
  final List<ActiveStreamingChunk> Function()? getActiveChunks;
  final List<PositionedChunk>? visibleChunks;
  final double containerWidth;
  final TextDirection textDirection;

  StreamingScrollPainter({
    super.repaint,
    this.controller,
    this.getActiveChunks,
    this.visibleChunks,
    required this.containerWidth,
    this.textDirection = TextDirection.ltr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (getActiveChunks != null && controller != null) {
      final double offset = controller!.offset;
      final chunks = getActiveChunks!();
      for (final chunk in chunks) {
        final double x;
        if (textDirection == TextDirection.ltr) {
          x = containerWidth - offset + chunk.startOffset;
        } else {
          x = -chunk.width - chunk.startOffset + offset;
        }
        final double textDrawY = (size.height - chunk.painter.height) / 2;
        chunk.painter.paint(canvas, Offset(x, textDrawY));
      }
    } else if (visibleChunks != null) {
      for (final chunk in visibleChunks!) {
        final double textDrawY = (size.height - chunk.painter.height) / 2;
        chunk.painter.paint(canvas, Offset(chunk.x, textDrawY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant StreamingScrollPainter oldDelegate) {
    return true;
  }
}
