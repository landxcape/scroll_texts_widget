import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A highly efficient, modular widget for smoothly scrolling a list of text strings.
///
/// This widget uses [CustomPainter] and [Ticker] for pixel-wise rendering and animation,
/// ensuring high performance and a scroll speed independent of the device's animation scale.
/// It renders only the viewable portion of the text, making it suitable for extremely
/// long strings without significant performance overhead.
class ScrollTextsWidget extends StatefulWidget {
  /// The list of strings to cycle and scroll through.
  final List<String> texts;

  /// The style applied to the text.
  final TextStyle textStyle;

  /// The speed of the scroll in pixels per second (px/s).
  /// This ensures all texts, regardless of length, scroll at a consistent velocity.
  final double scrollSpeed;

  /// The duration to pause after one text has fully scrolled off-screen
  /// before the next text begins its scroll.
  final Duration pauseDuration;

  /// The direction the text should be laid out and scrolled.
  /// Defaults to [TextDirection.ltr] (Left-to-Right scrolling).
  final TextDirection textDirection;

  const ScrollTextsWidget({
    super.key,
    required this.texts,
    this.textStyle = const TextStyle(fontSize: 18.0, color: Colors.black),
    this.scrollSpeed = 50.0,
    this.pauseDuration = const Duration(seconds: 2),
    this.textDirection = TextDirection.ltr,
  });

  @override
  State<ScrollTextsWidget> createState() => _ScrollTextsWidgetState();
}

class _ScrollTextsWidgetState extends State<ScrollTextsWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _scrollOffset = 0.0;
  int _currentTextIndex = -1;
  bool _isPaused = true;
  double _textWidth = 0.0;
  double _textHeight = 0.0;
  double _containerWidth = 0.0;
  Duration? _lastElapsedDuration;

  @override
  void initState() {
    super.initState();
    if (widget.texts.isEmpty) return;
    _ticker = createTicker(_tick);
    _startInitialScroll();
  }

  void _tick(Duration elapsed) {
    if (_isPaused || widget.texts.isEmpty) return;

    final double deltaTimeSeconds;
    if (_lastElapsedDuration == null) {
      deltaTimeSeconds = 0.0;
    } else {
      deltaTimeSeconds =
          (elapsed - _lastElapsedDuration!).inMicroseconds / 1000000.0;
    }
    _lastElapsedDuration = elapsed;

    final distanceMoved = widget.scrollSpeed * deltaTimeSeconds;
    final totalScrollDistance = _textWidth + _containerWidth;

    setState(() {
      _scrollOffset += distanceMoved;
    });

    if (_scrollOffset >= totalScrollDistance) {
      _ticker.stop();
      _cycleNextText();
    }
  }

  void _startInitialScroll() {
    _currentTextIndex = 0;
    _updateTextDimensions(widget.texts[_currentTextIndex]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isPaused = false;
        _ticker.start();
      });
    });
  }

  void _cycleNextText() async {
    _isPaused = true;
    _scrollOffset = 0.0;
    _lastElapsedDuration = null;

    _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
    _updateTextDimensions(widget.texts[_currentTextIndex]);

    setState(() {});

    await Future<void>.delayed(widget.pauseDuration);

    _isPaused = false;
    _ticker.start();
  }

  /// Updates both [_textWidth] and [_textHeight] for the current text using [TextPainter].
  void _updateTextDimensions(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: widget.textStyle),
      textDirection: widget.textDirection,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    _textWidth = textPainter.width;
    _textHeight = textPainter.height;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.texts.isEmpty || _currentTextIndex == -1) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;

        // Constrain the height of the CustomPaint using the pixel-perfect height
        // calculated by TextPainter to prevent vertical overflow.
        return SizedBox(
          height: _textHeight,
          width: constraints.maxWidth,
          child: ClipRect(
            child: CustomPaint(
              size: Size(constraints.maxWidth, _textHeight),
              painter: _ScrollTextPainter(
                text: widget.texts[_currentTextIndex],
                textStyle: widget.textStyle,
                scrollOffset: _scrollOffset,
                containerWidth: _containerWidth,
                textWidth: _textWidth,
                textDirection: widget.textDirection,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// Renders the text using [CustomPainter] and calculates the precise
/// position based on the scroll offset and text direction.
///
/// This custom painting ensures that only the visible portion of the text
/// is rendered on the canvas, optimizing performance for long strings.
class _ScrollTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double scrollOffset;
  final double containerWidth;
  final double textWidth;
  final TextDirection textDirection;

  _ScrollTextPainter({
    required this.text,
    required this.textStyle,
    required this.scrollOffset,
    required this.containerWidth,
    required this.textWidth,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: textDirection,
    );

    textPainter.layout(minWidth: 0, maxWidth: double.infinity);

    final double textDrawX;

    // Invert the scroll origin based on direction.
    if (textDirection == TextDirection.ltr) {
      // LTR: Text scrolls Right-to-Left (Enters from containerWidth, moves left).
      textDrawX = containerWidth - scrollOffset;
    } else {
      // RTL: Text scrolls Left-to-Right (Enters from -textWidth, moves right).
      textDrawX = -textWidth + scrollOffset;
    }

    // Vertical centering
    final double textDrawY = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(textDrawX, textDrawY));
  }

  /// Repaints only when the scroll offset, text content, or direction changes.
  @override
  bool shouldRepaint(covariant _ScrollTextPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.text != text ||
        oldDelegate.textDirection != textDirection;
  }
}
