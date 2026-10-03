# scroll_texts_widget

A highly efficient and modular Flutter widget for creating scrolling marquee text banners.

Unlike standard marquee widgets that struggle with long strings, force full widget-tree rebuilds, or warp speeds due to device animation scales, `scroll_texts_widget` uses **direct Canvas rendering via `CustomPainter` and a standalone `Ticker`** to guarantee smooth, 60/120fps scrolling.

## ✨ Key Features

* **🪟 Dual Render Modes:**
  * **Cached Mode:** Measures text once and clips on the GPU. Delivers 100% typographic fidelity (BiDi, complex scripts, kerning) with zero per-frame layout overhead.
  * **Streaming Mode:** Employs a sliding window algorithm that measures and renders **only** the words/chunks currently visible inside the viewport box. Retains strictly $O(\text{viewport})$ memory and eliminates UI freezes even with 50,000-word strings.
  * **Auto Mode (Default):** Automatically chooses the best mode based on string length.
* **🎮 Full Controller Support:** Use `ScrollTextsController` to programmatically play, pause, toggle pause, read the exact pixel offset, inspect the active text index, or jump directly to any position or announcement in the list.
* **⏱️ Consistent Velocity (Pixels/Sec):** Configured via `scrollSpeed` (px/s), guaranteeing uniform visual velocity regardless of text length.
* **⚙️ Platform-Independent Frame Timing:** Uses a direct `Ticker` with microsecond delta-time tracking ($\Delta x = \text{speed} \times \Delta t$), making the scroll rate immune to OS animation scaling and ProMotion 120Hz refresh rates.
* **🌍 First-Class RTL Support:** Full support for `TextDirection.rtl` (Arabic, Hebrew) adjusting layout and scrolling direction.
* **📏 Intrinsic Auto-Sizing:** Measures font metrics upfront to match the exact text height, preventing layout overflow errors.

---

## 💻 Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:scroll_texts_widget/scroll_texts_widget.dart';

class MyMarqueeApp extends StatelessWidget {
  const MyMarqueeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marquee Demo')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.blueGrey.shade100,
          child: ScrollTextsWidget(
            texts: const [
              'Welcome to the scroll_texts_widget package.',
              'This text will scroll at a consistent 75 pixels per second!',
            ],
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            scrollSpeed: 75.0,
            pauseDuration: const Duration(seconds: 1),
          ),
        ),
      ),
    );
  }
}
```

### Advanced Example with Controller & Callbacks

```dart
final controller = ScrollTextsController(
  initialScrollOffset: 0.0,
  initialTextIndex: 0,
);

// Programmatic controls
controller.pause();
controller.resume();
controller.togglePause();
controller.jumpTo(150.0); // Jump to 150px in the current text
controller.jumpToText(2);  // Skip to 3rd announcement

ScrollTextsWidget(
  texts: myAnnouncements,
  controller: controller,
  renderMode: ScrollTextRenderMode.auto,
  scrollSpeed: 90.0,
  pauseDuration: const Duration(seconds: 2),
  textDirection: TextDirection.ltr,
  onScrollChanged: (offset, textIndex) {
    print('Scrolled to offset: $offset on text #$textIndex');
  },
  onTextCompleted: (completedIndex) {
    print('Completed text #$completedIndex');
  },
)
```

---

## 📖 API Reference

### `ScrollTextsWidget` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `texts` | `List<String>` | **Required** | The list of strings to cycle and scroll through. |
| `controller` | `ScrollTextsController?` | `null` | Optional controller for reading position and programmatic playback/seeking. |
| `scrollSpeed` | `double` | `50.0` | Velocity in pixels per second (px/s). |
| `pauseDuration` | `Duration` | `Duration(seconds: 2)` | Duration to pause after a text exits before the next starts. |
| `repeat` | `bool` | `true` | Whether to continuously loop through the text playlist. |
| `renderMode` | `ScrollTextRenderMode` | `.auto` | Rendering strategy: `.auto`, `.cached`, or `.streaming`. |
| `textStyle` | `TextStyle` | `18px black` | Font style applied to the scrolling text. |
| `textDirection` | `TextDirection` | `TextDirection.ltr` | Layout and scroll direction (`.ltr` scrolls left, `.rtl` scrolls right). |
| `initialScrollOffset` | `double` | `0.0` | Initial starting pixel offset for the active text. |
| `initialTextIndex` | `int` | `0` | Starting index in `texts`. |
| `onScrollChanged` | `Function(double, int)?` | `null` | Callback invoked as the scroll offset changes. |
| `onTextCompleted` | `Function(int)?` | `null` | Callback invoked when an active text finishes scrolling. |

### `ScrollTextsController` API

| Member | Type | Description |
| :--- | :--- | :--- |
| `offset` | `double` (getter) | The current scroll offset in pixels. |
| `currentTextIndex` | `int` (getter) | The index of the active text in the playlist. |
| `isPaused` | `bool` (getter) | Whether scrolling is currently paused. |
| `pause()` | `void` | Pauses the scrolling animation. |
| `resume()` | `void` | Resumes scrolling. |
| `togglePause()` | `void` | Toggles between paused and scrolling states. |
| `jumpTo(double offset)` | `void` | Instantly jumps the active text to the given pixel offset. |
| `jumpToText(int textIndex, {double offset = 0.0})` | `void` | Jumps to a specific text in `texts` at an optional starting offset. |

---

## 🛠️ Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  scroll_texts_widget: ^0.1.0
```
