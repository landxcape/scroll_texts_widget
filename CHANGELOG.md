# Changelog

## 0.1.0

✨ **Major Architecture & Performance Overhaul** ✨

### 🚀 New Features & Enhancements
- **Dual Render Modes (`ScrollTextRenderMode`):**
  - **`cached`**: Pre-measures single `TextPainter` and uses GPU clipping with zero layout operations inside `paint()`.
  - **`streaming`**: Implements a sliding window tokenizer and queue that measures and paints **only** the text chunks currently visible inside the viewport window, delivering $O(\text{viewport})$ constant memory overhead.
  - **`auto`**: Dynamically engages streaming for long texts and cached for short texts.
- **`ScrollTextsController`:**
  - Read real-time pixel `offset`, `currentTextIndex`, and `isPaused`.
  - Programmatic controls: `jumpTo(double offset)`, `jumpToText(int index, {double offset})`, `pause()`, `resume()`, and `togglePause()`.
- **Position Initialization & Event Callbacks:**
  - Added `initialScrollOffset` and `initialTextIndex`.
  - Added `initialDelay` to configure startup pause before first scroll begins.
  - Added `repeat` to configure continuous playlist looping vs. single-pass playback.
  - Added `onScrollChanged(double offset, int textIndex)` and `onTextCompleted(int textIndex)` callbacks.

### 🔧 Bug Fixes & Stability
- Fixed `LateInitializationError` thrown when disposing widget with an empty `texts` list.
- Fixed unmounted async execution exception during `pauseDuration` by adding `mounted` guards.
- Fixed inter-text pause cycling to guarantee subsequent texts begin scrolling after `pauseDuration`.
- Fixed dynamic mid-scroll render mode switching across `auto`, `cached`, and `streaming` modes.
- Implemented `didUpdateWidget` for dynamic updates of texts, speed, text styles, and controllers.
- Eliminated full-widget `setState()` rebuilds on each ticker frame by repainting via `ChangeNotifier` listenables directly on `CustomPaint`.
- Added unbounded constraint fallback protection in `LayoutBuilder`.

---

## 0.0.1

🎉 Initial Release 🎉
- Initial release with `ScrollTextsWidget` marquee scrolling.
