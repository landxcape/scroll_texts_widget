import 'package:flutter/foundation.dart';

/// A controller for a `ScrollTextsWidget`.
///
/// Can be used to read current scroll offset and text index, pause/resume,
/// or jump to specific positions in the scrolling playlist.
class ScrollTextsController extends ChangeNotifier {
  double _offset;
  int _currentTextIndex;
  bool _isPaused;

  void Function(double offset)? onJumpToRequested;
  void Function(int index, double offset)? onJumpToTextRequested;
  void Function()? onPauseRequested;
  void Function()? onResumeRequested;

  ScrollTextsController({
    double initialScrollOffset = 0.0,
    int initialTextIndex = 0,
    bool initialPaused = false,
  }) : _offset = initialScrollOffset,
       _currentTextIndex = initialTextIndex,
       _isPaused = initialPaused;

  /// The current scroll offset in pixels.
  double get offset => _offset;

  /// The index of the currently active text string in the playlist.
  int get currentTextIndex => _currentTextIndex;

  /// Whether the scrolling ticker is currently paused.
  bool get isPaused => _isPaused;

  /// Internal update invoked by the widget driver.
  void updateState({
    required double offset,
    required int textIndex,
    required bool isPaused,
  }) {
    final changed =
        _offset != offset ||
        _currentTextIndex != textIndex ||
        _isPaused != isPaused;
    _offset = offset;
    _currentTextIndex = textIndex;
    _isPaused = isPaused;
    if (changed) {
      notifyListeners();
    }
  }

  /// Jumps the current text to the given pixel [offset].
  void jumpTo(double offset) {
    _offset = offset;
    notifyListeners();
    onJumpToRequested?.call(offset);
  }

  /// Jumps to the text at [textIndex] with an optional starting pixel [offset].
  void jumpToText(int textIndex, {double offset = 0.0}) {
    _currentTextIndex = textIndex;
    _offset = offset;
    notifyListeners();
    onJumpToTextRequested?.call(textIndex, offset);
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
