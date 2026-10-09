# scroll_texts_widget

A horizontal marquee text banner widget for Flutter.

It renders text directly to the canvas and uses a timer ticker so text scrolls at a steady speed regardless of display refresh rate or screen size.

## Features

* **Dual Render Modes:**
  * **Cached Mode:** Measures text once upfront. Best for short-to-medium announcements.
  * **Streaming Mode:** Measures and draws only the words currently on screen. Helpful for very long texts.
  * **Auto Mode (Default):** Picks between cached and streaming based on text length.
* **Playback Controller:** Use `ScrollTextsController` to play, pause, jump to an offset, or skip to a specific item in the list.
* **Consistent Speed:** Set the scroll speed in pixels per second so it moves at the same pace no matter how long the text is.
* **RTL Support:** Full support for right-to-left languages like Arabic and Hebrew.
* **Auto Height:** Automatically sizes its height to match the text style.

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

## Recipes
 
Because this widget focuses on rendering the scrolling text, you can add interactions like hover, tap, or edge fading using standard Flutter widgets (`MouseRegion`, `GestureDetector`, `ShaderMask`).

### 1. Pause on Hover (Desktop & Web)

Pause the ticker when the cursor hovers over it, and resume when it leaves:

```dart
final controller = ScrollTextsController();

MouseRegion(
  onEnter: (_) => controller.pause(),
  onExit: (_) => controller.resume(),
  child: ScrollTextsWidget(
    texts: myAnnouncements,
    controller: controller,
  ),
);
```

### 2. Interactive Tappable Headlines

Detect taps on the active headline to navigate or open news details:

```dart
final controller = ScrollTextsController();

GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () {
    final activeIndex = controller.currentTextIndex;
    final activeHeadline = myAnnouncements[activeIndex];
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticlePage(headline: activeHeadline)),
    );
  },
  child: ScrollTextsWidget(
    texts: myAnnouncements,
    controller: controller,
  ),
);
```

### 3. Soft Edge Fading (Gradient Fade)

Fade the text seamlessly as it enters and leaves the viewport edges using `ShaderMask`:

```dart
ShaderMask(
  shaderCallback: (rect) {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        Colors.black,
        Colors.black,
        Colors.transparent,
      ],
      stops: [0.0, 0.08, 0.92, 1.0],
    ).createShader(rect);
  },
  blendMode: BlendMode.dstIn,
  child: ScrollTextsWidget(
    texts: myAnnouncements,
  ),
);
```

### 4. Platform-Adaptive Composition

Only register `MouseRegion` on desktop and web, keeping iOS, Android, and embedded displays 100% free from mouse-tracker hit testing:

```dart
import 'package:flutter/foundation.dart';

Widget ticker = ScrollTextsWidget(
  texts: myAnnouncements,
  controller: controller,
);

if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
  ticker = MouseRegion(
    onEnter: (_) => controller.pause(),
    onExit: (_) => controller.resume(),
    child: ticker,
  );
}
```

---

## How It Works

* **Canvas Drawing:** Uses `CustomPainter` to draw text directly to the canvas instead of scrolling a widget tree.
* **Frame Timing:** Updates pixel position on each tick using elapsed time, keeping the speed steady across different screen refresh rates.
* **Multiple Texts:** Takes a list of strings and automatically cycles through them with a configurable pause between each.
* **Long Text Handling:** Uses a sliding viewport approach for unusually long texts so only the visible portion is laid out at any moment.

---

## 📖 API Reference

### `ScrollTextsWidget` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `texts` | `List<String>` | **Required** | The list of strings to cycle and scroll through. |
| `controller` | `ScrollTextsController?` | `null` | Optional controller for reading position and programmatic playback/seeking. |
| `scrollSpeed` | `double` | `50.0` | Velocity in pixels per second (px/s). |
| `pauseDuration` | `Duration` | `Duration(seconds: 2)` | Duration to pause after a text exits before the next text starts. |
| `initialDelay` | `Duration` | `Duration.zero` | Optional delay before the very first text begins scrolling. |
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
| `maxScrollExtent` | `double` (getter) | The total scroll distance for the active text. |
| `progress` | `double` (getter) | Normalized scroll progress from `0.0` to `1.0`. |
| `effectiveRenderMode` | `ScrollTextRenderMode` (getter) | The active render mode engaged (`cached` or `streaming`), useful when `auto` is selected. |
| `currentTextIndex` | `int` (getter) | The index of the active text in the playlist. |
| `isPaused` | `bool` (getter) | Whether scrolling is currently paused. |
| `pause()` | `void` | Pauses the scrolling animation. |
| `resume()` | `void` | Resumes scrolling. |
| `togglePause()` | `void` | Toggles between paused and scrolling states. |
| `jumpTo(double offset)` | `void` | Instantly jumps the active text to the given pixel offset. |
| `jumpToText(int textIndex, {double offset = 0.0})` | `void` | Jumps to a specific text in `texts` at an optional starting offset. |

---

## 🛠️ Installation

Add the package via the Flutter CLI:

```bash
flutter pub add scroll_texts_widget
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  scroll_texts_widget: ^<latest-version>
```
