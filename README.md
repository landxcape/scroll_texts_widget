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
      appBar: AppBar(title: const Text('Efficient Marquee Demo')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.blueGrey.shade100,
          child: ScrollTextsWidget(
            texts: const [
              'Welcome to the highly efficient Flutter scroll text package.',
              'This text will scroll at a consistent 75 pixels per second!',
            ],
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            scrollSpeed: 75.0, // 75 pixels per second
            pauseDuration: const Duration(seconds: 1),
          ),
        ),
      ),
    );
  }
}
```

### Advanced Example with Controller & Streaming

```dart
final controller = ScrollTextsController();

// Monitor state or programmatic controls
controller.pause();
controller.resume();
controller.togglePause();
controller.jumpTo(250.0); // Jump to 250px offset
controller.jumpToText(2);  // Skip to 3rd announcement

ScrollTextsWidget(
  texts: myLongArticlesOrAnnouncements,
  controller: controller,
  renderMode: ScrollTextRenderMode.auto, // Or .streaming for massive text
  scrollSpeed: 90.0,
  pauseDuration: const Duration(seconds: 2),
  onScrollChanged: (offset, textIndex) {
    // Current pixel offset and active text index
  },
  onTextCompleted: (completedIndex) {
    // Triggered when an announcement finishes
  },
)
```

## 🛠️ Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  scroll_texts_widget: ^0.1.0
```
