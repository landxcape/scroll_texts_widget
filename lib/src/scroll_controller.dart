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
  List<String> _texts;

  /// Callback registered by the attached widget to handle jumps to an offset.
  void Function(double offset)? onJumpToRequested;

  /// Callback registered by the attached widget to handle jumps to an index and offset.
  void Function(int index, double offset)? onJumpToTextRequested;

  /// Callback registered by the attached widget to handle pause requests.
  void Function()? onPauseRequested;

  /// Callback registered by the attached widget to handle resume requests.
  void Function()? onResumeRequested;

  /// Callback registered by the attached widget to handle adding a text.
  void Function(String text)? onAddTextRequested;

  /// Callback registered by the attached widget to handle inserting a text.
  void Function(int index, String text)? onInsertTextRequested;

  /// Callback registered by the attached widget to handle removing a text at an index.
  void Function(int index)? onRemoveTextAtRequested;

  /// Callback registered by the attached widget to handle clearing all texts.
  void Function()? onClearTextsRequested;

  /// Callback registered by the attached widget to handle replacing all texts.
  void Function(List<String> texts)? onSetTextsRequested;

  /// Callback registered by the attached widget to retrieve the live effective texts.
  List<String> Function()? onGetTextsRequested;

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
       _maxScrollExtent = initialMaxScrollExtent,
       _texts = [];

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

  /// An unmodifiable view of the current texts in the playlist.
  List<String> get texts =>
      onGetTextsRequested?.call() ?? List.unmodifiable(_texts);

  /// Internal update invoked by the widget driver.
  void updateState({
    required double offset,
    required int textIndex,
    required bool isPaused,
    ScrollTextRenderMode? effectiveRenderMode,
    double? maxScrollExtent,
    List<String>? texts,
  }) {
    final changed =
        _offset != offset ||
        _currentTextIndex != textIndex ||
        _isPaused != isPaused ||
        (effectiveRenderMode != null &&
            _effectiveRenderMode != effectiveRenderMode) ||
        (maxScrollExtent != null && _maxScrollExtent != maxScrollExtent) ||
        (texts != null && !listEquals(_texts, texts));

    _offset = offset;
    _currentTextIndex = textIndex;
    _isPaused = isPaused;
    if (effectiveRenderMode != null) {
      _effectiveRenderMode = effectiveRenderMode;
    }
    if (maxScrollExtent != null) {
      _maxScrollExtent = maxScrollExtent;
    }
    if (texts != null) {
      _texts = List<String>.from(texts);
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

  /// Appends a new [text] to the end of the scrolling playlist.
  void addText(String text) {
    _texts.add(text);
    onAddTextRequested?.call(text);
    notifyListeners();
  }

  /// Inserts a new [text] at [index] in the scrolling playlist.
  void insertText(int index, String text) {
    if (index >= 0 && index <= _texts.length) {
      _texts.insert(index, text);
    } else {
      _texts.add(text);
    }
    onInsertTextRequested?.call(index, text);
    notifyListeners();
  }

  /// Removes the text at [index] from the scrolling playlist.
  void removeTextAt(int index) {
    if (index >= 0 && index < _texts.length) {
      _texts.removeAt(index);
    }
    onRemoveTextAtRequested?.call(index);
    notifyListeners();
  }

  /// Clears all texts from the scrolling playlist.
  void clearTexts() {
    _texts.clear();
    onClearTextsRequested?.call();
    notifyListeners();
  }

  /// Replaces the entire scrolling playlist with [texts].
  void setTexts(List<String> texts) {
    _texts = List<String>.from(texts);
    onSetTextsRequested?.call(texts);
    notifyListeners();
  }
}
