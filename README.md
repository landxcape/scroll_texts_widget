# scroll_texts_widget

[![pub package](https://img.shields.io/pub/v/scroll_texts_widget.svg)](https://pub.dev/packages/scroll_texts_widget)

A highly efficient and modular Flutter widget for creating scrolling marquee text banners.

Unlike standard Flutter widgets that may struggle with long strings or rely on the device's animation scale, `scroll_texts_widget` uses **CustomPainter and a custom Ticker** to ensure smooth, pixel-perfect scrolling with maximum performance efficiency.

## ✨ Key Features

* **🚀 Efficient Partial Rendering:** Utilizes **CustomPainter** to render **only the visible portion of the text**. This makes it exceptionally performant for long texts, as the framework never lays out or renders off-screen elements.
* **⏱️ Consistent Scroll Speed:** Animation is controlled by a user-defined **pixels-per-second (`scrollSpeed`)** value, guaranteeing uniform velocity across texts of varying lengths.
* **⚙️ Platform-Independent Animation:** Uses a `Ticker` instead of `AnimationController` to bypass the device's animation scale settings, ensuring the scroll speed is always accurate.
* **🌍 RTL Support:** Explicitly handles `TextDirection.rtl` for languages like Arabic and Hebrew, adjusting both the text layout and the scrolling direction (Left-to-Right).
* **📏 Auto-Sizing:** Automatically adjusts its height to perfectly match the height of the rendered text, preventing vertical overflow errors.

## 💻 Usage

To use this package, simply provide a list of strings and configure your desired style and speed.

### Example

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
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            scrollSpeed: 75.0, // 75 pixels per second
            pauseDuration: const Duration(seconds: 1),
            // Example of RTL usage
            textDirection: TextDirection.rtl, 
          ),
        ),
      ),
    );
  }
}
```

## 🛠️ Installation

Add the following to your pubspec.yaml file:

```YAML
  dependencies:
    scroll_texts_widget: ^latest_version
```
