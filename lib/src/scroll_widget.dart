import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'painters/cached_scroll_painter.dart';
import 'painters/streaming_scroll_painter.dart';
import 'render_mode.dart';
import 'scroll_controller.dart';
import 'streaming_tokenizer.dart';

/// A highly efficient, modular widget for smoothly scrolling a list of text strings.
///
/// Supports dual render modes:
/// - [ScrollTextRenderMode.cached]: Lays out text once and clips on GPU.
/// - [ScrollTextRenderMode.streaming]: Sliding window layout that only measures
///   and renders what is physically visible in the widget window.
/// - [ScrollTextRenderMode.auto]: Automatically selects the optimal mode.
class ScrollTextsWidget extends StatefulWidget {
  /// The list of strings to cycle and scroll through.
  final List<String> texts;

  /// The style applied to the text.
  final TextStyle textStyle;

  /// The speed of the scroll in pixels per second (px/s).
  final double scrollSpeed;

  /// The duration to pause after one text has fully scrolled off-screen
  /// before the next text begins its scroll.
  final Duration pauseDuration;

  /// The direction the text should be laid out and scrolled.
  /// Defaults to [TextDirection.ltr] (Left-to-Right scrolling).
  final TextDirection textDirection;

  /// Rendering strategy to use. Defaults to [ScrollTextRenderMode.auto].
  final ScrollTextRenderMode renderMode;

  /// Optional controller to monitor position, pause/resume, or jump.
  final ScrollTextsController? controller;

  /// Initial pixel scroll offset for the first text.
  final double initialScrollOffset;

  /// Initial text index from [texts] to display.
  final int initialTextIndex;

  /// Optional callback invoked as the scroll offset changes.
  final void Function(double offset, int textIndex)? onScrollChanged;

  /// Optional callback invoked when a text has completed its full scroll.
  final void Function(int textIndex)? onTextCompleted;

  const ScrollTextsWidget({
    super.key,
    required this.texts,
    this.textStyle = const TextStyle(fontSize: 18.0, color: Colors.black),
    this.scrollSpeed = 50.0,
    this.pauseDuration = const Duration(seconds: 2),
    this.textDirection = TextDirection.ltr,
    this.renderMode = ScrollTextRenderMode.auto,
    this.controller,
    this.initialScrollOffset = 0.0,
    this.initialTextIndex = 0,
    this.onScrollChanged,
    this.onTextCompleted,
  });

  @override
  State<ScrollTextsWidget> createState() => _ScrollTextsWidgetState();
}

class _ActiveStreamingToken extends ActiveStreamingChunk {
  final int index;
  final String text;

  _ActiveStreamingToken({
    required this.index,
    required this.text,
    required super.painter,
    required super.width,
    required super.startOffset,
  });
}

class _ScrollTextsWidgetState extends State<ScrollTextsWidget>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  ScrollTextsController? _internalController;

  ScrollTextsController get _effectiveController =>
      widget.controller ?? (_internalController ??= ScrollTextsController());

  double _scrollOffset = 0.0;
  int _currentTextIndex = 0;
  bool _isPaused = false;
  double _containerWidth = 300.0;
  double _textHeight = 0.0;
  Duration? _lastElapsedDuration;

  // Cached mode state
  TextPainter? _cachedTextPainter;
  double _cachedTextWidth = 0.0;

  // Streaming mode state
  List<String> _tokens = const [];
  final List<double?> _tokenWidths = [];
  final List<_ActiveStreamingToken> _activeTokens = [];
  int _nextTokenIndex = 0;
  double _nextTokenStartOffset = 0.0;
  double _streamingTotalDistance = double.infinity;

  @override
  void initState() {
    super.initState();
    _currentTextIndex = (widget.texts.isNotEmpty &&
            widget.initialTextIndex < widget.texts.length &&
            widget.initialTextIndex >= 0)
        ? widget.initialTextIndex
        : 0;
    _scrollOffset = widget.initialScrollOffset;

    _attachController();
    _measureTextHeight();

    _ticker = createTicker(_tick);

    if (widget.texts.isNotEmpty) {
      _prepareActiveText();
      if (!_isPaused) {
        _ticker?.start();
      }
    }
  }

  void _attachController() {
    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: _isPaused,
    );
    _effectiveController.onJumpToRequested = _handleJumpTo;
    _effectiveController.onJumpToTextRequested = _handleJumpToText;
    _effectiveController.onPauseRequested = _handlePause;
    _effectiveController.onResumeRequested = _handleResume;
  }

  void _detachController(ScrollTextsController controller) {
    controller.onJumpToRequested = null;
    controller.onJumpToTextRequested = null;
    controller.onPauseRequested = null;
    controller.onResumeRequested = null;
  }

  bool _isStreamingActive(String text) {
    if (widget.renderMode == ScrollTextRenderMode.streaming) return true;
    if (widget.renderMode == ScrollTextRenderMode.cached) return false;
    return text.length >= 300;
  }

  void _measureTextHeight() {
    final samplePainter = TextPainter(
      text: TextSpan(text: 'Aj', style: widget.textStyle),
      textDirection: widget.textDirection,
    );
    samplePainter.layout(minWidth: 0, maxWidth: double.infinity);
    _textHeight = samplePainter.height;
  }

  void _prepareActiveText() {
    if (widget.texts.isEmpty || _currentTextIndex >= widget.texts.length) {
      return;
    }

    final currentText = widget.texts[_currentTextIndex];
    if (_isStreamingActive(currentText)) {
      _cachedTextPainter = null;
      _tokens = StreamingTokenizer.tokenize(currentText);
      _tokenWidths
        ..clear()
        ..addAll(List<double?>.filled(_tokens.length, null));
      _rebuildStreamingWindow(_scrollOffset);
    } else {
      _activeTokens.clear();
      _tokens = const [];
      _cachedTextPainter = TextPainter(
        text: TextSpan(text: currentText, style: widget.textStyle),
        textDirection: widget.textDirection,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      _cachedTextWidth = _cachedTextPainter!.width;
      _textHeight = math.max(_textHeight, _cachedTextPainter!.height);
    }
  }

  void _tick(Duration elapsed) {
    if (_isPaused || widget.texts.isEmpty) return;

    final double deltaTimeSeconds;
    if (_lastElapsedDuration == null) {
      deltaTimeSeconds = elapsed.inMicroseconds / 1000000.0;
    } else {
      deltaTimeSeconds =
          (elapsed - _lastElapsedDuration!).inMicroseconds / 1000000.0;
    }
    _lastElapsedDuration = elapsed;

    if (deltaTimeSeconds <= 0) return;

    final distanceMoved = widget.scrollSpeed * deltaTimeSeconds;
    _scrollOffset += distanceMoved;

    final currentText = widget.texts[_currentTextIndex];
    final bool isStreaming = _isStreamingActive(currentText);

    if (isStreaming) {
      _updateStreamingWindow();
    }

    final double totalDistance = isStreaming
        ? _streamingTotalDistance
        : (_cachedTextWidth + _containerWidth);

    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: _isPaused,
    );
    widget.onScrollChanged?.call(_scrollOffset, _currentTextIndex);

    if (_scrollOffset >= totalDistance) {
      _ticker?.stop();
      _cycleNextText();
    }
  }

  double _measureTokenWidth(String token) {
    final painter = TextPainter(
      text: TextSpan(text: token, style: widget.textStyle),
      textDirection: widget.textDirection,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    _textHeight = math.max(_textHeight, painter.height);
    return painter.width;
  }

  void _rebuildStreamingWindow(double offset) {
    _activeTokens.clear();
    _nextTokenIndex = 0;
    _nextTokenStartOffset = 0.0;

    final minOffset = offset - _containerWidth;
    final maxOffset = offset + _containerWidth;

    while (_nextTokenIndex < _tokens.length) {
      if (_nextTokenStartOffset > maxOffset) {
        break;
      }

      final tokenText = _tokens[_nextTokenIndex];
      final double width = _tokenWidths[_nextTokenIndex] ??=
          _measureTokenWidth(tokenText);
      final double tokenStart = _nextTokenStartOffset;
      final double tokenEnd = tokenStart + width;

      if (tokenEnd >= minOffset && tokenStart <= maxOffset) {
        final painter = TextPainter(
          text: TextSpan(text: tokenText, style: widget.textStyle),
          textDirection: widget.textDirection,
        )..layout(minWidth: 0, maxWidth: double.infinity);
        _textHeight = math.max(_textHeight, painter.height);

        _activeTokens.add(
          _ActiveStreamingToken(
            index: _nextTokenIndex,
            text: tokenText,
            painter: painter,
            width: width,
            startOffset: tokenStart,
          ),
        );
      }

      _nextTokenStartOffset += width;
      _nextTokenIndex++;
    }

    if (_nextTokenIndex >= _tokens.length) {
      _streamingTotalDistance = _nextTokenStartOffset + _containerWidth;
    } else {
      _streamingTotalDistance = double.infinity;
    }
  }

  void _updateStreamingWindow() {
    if (_tokens.isEmpty) return;

    if (_activeTokens.isEmpty ||
        _scrollOffset < (_activeTokens.first.startOffset - _containerWidth) ||
        _scrollOffset > (_nextTokenStartOffset + _containerWidth)) {
      _rebuildStreamingWindow(_scrollOffset);
      return;
    }

    // 1. Advance and measure tokens entering the visible window on the entry edge
    final maxOffset = _scrollOffset + _containerWidth;
    while (_nextTokenIndex < _tokens.length) {
      if (_nextTokenStartOffset > maxOffset) {
        break;
      }

      final tokenText = _tokens[_nextTokenIndex];
      final painter = TextPainter(
        text: TextSpan(text: tokenText, style: widget.textStyle),
        textDirection: widget.textDirection,
      )..layout(minWidth: 0, maxWidth: double.infinity);

      final width = painter.width;
      _textHeight = math.max(_textHeight, painter.height);
      _tokenWidths[_nextTokenIndex] = width;

      if (_nextTokenStartOffset + width >= _scrollOffset - _containerWidth) {
        _activeTokens.add(
          _ActiveStreamingToken(
            index: _nextTokenIndex,
            text: tokenText,
            painter: painter,
            width: width,
            startOffset: _nextTokenStartOffset,
          ),
        );
      }

      _nextTokenStartOffset += width;
      _nextTokenIndex++;
    }

    if (_nextTokenIndex >= _tokens.length) {
      _streamingTotalDistance = _nextTokenStartOffset + _containerWidth;
    }

    // 2. Remove tokens that have scrolled completely past the exit edge
    final minOffset = _scrollOffset - _containerWidth;
    _activeTokens.removeWhere((token) {
      return (token.startOffset + token.width < minOffset);
    });
  }

  void _cycleNextText() async {
    _isPaused = true;
    _scrollOffset = 0.0;
    _lastElapsedDuration = null;

    final completedIndex = _currentTextIndex;
    widget.onTextCompleted?.call(completedIndex);

    if (widget.texts.isNotEmpty) {
      _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
      _prepareActiveText();
    }

    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: true,
    );

    if (mounted) {
      setState(() {});
    }

    if (widget.pauseDuration > Duration.zero) {
      await Future<void>.delayed(widget.pauseDuration);
    }

    if (!mounted) return;
    if (_effectiveController.isPaused) return;

    _isPaused = false;
    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: false,
    );
    _ticker?.start();
  }

  void _handleJumpTo(double offset) {
    _scrollOffset = offset;
    final currentText =
        widget.texts.isNotEmpty ? widget.texts[_currentTextIndex] : '';
    if (_isStreamingActive(currentText)) {
      _rebuildStreamingWindow(_scrollOffset);
    }
    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: _isPaused,
    );
  }

  void _handleJumpToText(int textIndex, double offset) {
    if (widget.texts.isEmpty) return;
    _currentTextIndex = textIndex.clamp(0, widget.texts.length - 1);
    _scrollOffset = offset;
    _lastElapsedDuration = null;
    _prepareActiveText();
    _effectiveController.updateState(
      offset: _scrollOffset,
      textIndex: _currentTextIndex,
      isPaused: _isPaused,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePause() {
    _isPaused = true;
    _ticker?.stop();
    _lastElapsedDuration = null;
  }

  void _handleResume() {
    if (widget.texts.isEmpty) return;
    _isPaused = false;
    _lastElapsedDuration = null;
    _ticker?.start();
  }

  @override
  void didUpdateWidget(ScrollTextsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        _detachController(oldWidget.controller!);
      }
      _attachController();
    }

    bool needsRebuild = false;

    if (widget.textStyle != oldWidget.textStyle ||
        widget.textDirection != oldWidget.textDirection ||
        widget.renderMode != oldWidget.renderMode) {
      _tokenWidths.clear();
      _measureTextHeight();
      _prepareActiveText();
      needsRebuild = true;
    }

    if (widget.texts != oldWidget.texts) {
      _tokenWidths.clear();
      if (widget.texts.isEmpty) {
        _ticker?.stop();
        _currentTextIndex = 0;
        _scrollOffset = 0.0;
      } else {
        if (_currentTextIndex >= widget.texts.length) {
          _currentTextIndex = 0;
          _scrollOffset = 0.0;
        }
        _prepareActiveText();
        if (!_isPaused && (_ticker?.isTicking == false)) {
          _ticker?.start();
        }
      }
      _effectiveController.updateState(
        offset: _scrollOffset,
        textIndex: _currentTextIndex,
        isPaused: _isPaused,
      );
      needsRebuild = true;
    }

    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.texts.isEmpty ||
        _currentTextIndex < 0 ||
        _currentTextIndex >= widget.texts.length) {
      return const SizedBox.shrink();
    }

    final currentText = widget.texts[_currentTextIndex];
    final bool isStreaming = _isStreamingActive(currentText);

    if (!isStreaming && _cachedTextPainter == null) {
      _prepareActiveText();
    } else if (isStreaming && _tokens.isEmpty && currentText.isNotEmpty) {
      _prepareActiveText();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final newContainerWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (MediaQuery.maybeSizeOf(context)?.width ?? 300.0);

        if (_containerWidth != newContainerWidth) {
          _containerWidth = newContainerWidth;
          if (isStreaming) {
            _updateStreamingWindow();
          }
        }

        final CustomPainter painter;
        if (isStreaming) {
          painter = StreamingScrollPainter(
            repaint: _effectiveController,
            controller: _effectiveController,
            getActiveChunks: () => _activeTokens,
            containerWidth: _containerWidth,
            textDirection: widget.textDirection,
          );
        } else {
          painter = CachedScrollPainter(
            repaint: _effectiveController,
            controller: _effectiveController,
            textPainter: _cachedTextPainter!,
            containerWidth: _containerWidth,
            textDirection: widget.textDirection,
          );
        }

        return SizedBox(
          height: _textHeight,
          width: _containerWidth,
          child: ClipRect(
            child: CustomPaint(
              size: Size(_containerWidth, _textHeight),
              painter: painter,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      _detachController(widget.controller!);
    } else {
      _internalController?.dispose();
    }
    _ticker?.dispose();
    super.dispose();
  }
}
