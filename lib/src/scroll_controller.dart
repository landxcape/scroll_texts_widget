import 'package:flutter/foundation.dart';
import 'render_mode.dart';

/// A controller for a `ScrollTextsWidget`.
///
/// Can be used to read current scroll offset, progress, active text index,
/// effective render mode, pause/resume, or jump to specific positions in the
/// scrolling playlist.
class ScrollTextsController extends ChangeNotifier {
  double _offset;
  int _currentTextIndex;
  bool _isPaused;
  ScrollTextRenderMode _effectiveRenderMode;
  double _maxScrollExtent;

  /// Callback registered by the attached widget to handle jumps to an offset.
  void Function(double offset)? onJumpToRequested;

  /// Callback registered by the attached widget to handle jumps to an index and offset.
  void Function(int index, double offset)? onJumpToTextRequested;

  /// Callback registered by the attached widget to handle pause requests.
  void Function()? onPauseRequested;

  /// Callback registered by the attached widget to handle resume requests.
  void Function()? onResumeRequested;

  /// Creates a controller to monitor and control a [ScrollTextsWidget].
  ScrollTextsController({
    double initialScrollOffset = 0.0,
    int initialTextIndex = 0,
    bool initialPaused = false,
    ScrollTextRenderMode initialRenderMode = ScrollTextRenderMode.cached,
    double initialMaxScrollExtent = 0.0,
  }) : _offset = initialScrollOffset,
       _currentTextIndex = initialTextIndex,
       _isPaused = initialPaused,
       _effectiveRenderMode = initialRenderMode,
       _maxScrollExtent = initialMaxScrollExtent;

  /// The current scroll offset in pixels.
  double get offset => _offset;

  /// The total scroll distance for the currently active text.
  double get maxScrollExtent => _maxScrollExtent;

  /// The normalized scroll progress of the active text from 0.0 to 1.0.
  double get progress => (_maxScrollExtent > 0.0 && _maxScrollExtent.isFinite)
      ? (_offset / _maxScrollExtent).clamp(0.0, 1.0)
      : 0.0;

  /// The active render mode currently selected and utilized by the engine.
  ///
  /// When `ScrollTextsWidget.renderMode` is set to [ScrollTextRenderMode.auto],
  /// this reveals whether [ScrollTextRenderMode.cached] or
  /// [ScrollTextRenderMode.streaming] is actively engaged.
  ScrollTextRenderMode get effectiveRenderMode => _effectiveRenderMode;

  /// The index of the currently active text string in the playlist.
  int get currentTextIndex => _currentTextIndex;

  /// Whether the scrolling ticker is currently paused.
  bool get isPaused => _isPaused;

  /// Internal update invoked by the widget driver.
  void updateState({
    required double offset,
    required int textIndex,
    required bool isPaused,
    ScrollTextRenderMode? effectiveRenderMode,
    double? maxScrollExtent,
  }) {
    final changed =
        _offset != offset ||
        _currentTextIndex != textIndex ||
        _isPaused != isPaused ||
        (effectiveRenderMode != null &&
            _effectiveRenderMode != effectiveRenderMode) ||
        (maxScrollExtent != null && _maxScrollExtent != maxScrollExtent);
    _offset = offset;
    _currentTextIndex = textIndex;
    _isPaused = isPaused;
    if (effectiveRenderMode != null) {
      _effectiveRenderMode = effectiveRenderMode;
    }
    if (maxScrollExtent != null) {
      _maxScrollExtent = maxScrollExtent;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Jumps the current text to the given pixel [offset].
  void jumpTo(double offset) {
    _offset = offset;
    onJumpToRequested?.call(offset);
    notifyListeners();
  }

  /// Jumps to the text at [textIndex] with an optional starting pixel [offset].
  void jumpToText(int textIndex, {double offset = 0.0}) {
    _currentTextIndex = textIndex;
    _offset = offset;
    onJumpToTextRequested?.call(textIndex, offset);
    notifyListeners();
  }

  /// Pauses scrolling.
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      notifyListeners();
      onPauseRequested?.call();
    }
  }

  /// Resumes scrolling.
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      notifyListeners();
      onResumeRequested?.call();
    }
  }

  /// Toggles between paused and scrolling states.
  void togglePause() {
    if (_isPaused) {
      resume();
    } else {
      pause();
    }
  }
}
