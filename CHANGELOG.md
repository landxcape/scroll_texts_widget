# Changelog

## 0.0.1

🎉 Initial Release 🎉

The first stable release of scroll_texts_widget introduces a highly efficient, modular, and performant solution for scrolling marquee text in Flutter.

✨ New Features
ScrollTextsWidget: The core widget for cycling and smoothly scrolling a list of strings.

Constant Scroll Speed: Introduced the scrollSpeed property (pixels per second) to guarantee a consistent scrolling velocity independent of the text length, replacing variable duration-based scrolling.

Explicit Text Direction: Added the textDirection property, defaulting to TextDirection.ltr, allowing users to explicitly control both the text layout and the scrolling direction, providing full support for RTL languages (e.g., Arabic, Hebrew).

🚀 Performance & Architecture
Efficient Partial Rendering: Implemented custom rendering using CustomPainter to draw only the visible portion of the text. This ensures high performance even with extremely long input strings, as the entire text is never laid out or rendered off-screen.

Platform-Independent Animation: Utilizes a Ticker for frame updates instead of AnimationController, ensuring the scroll speed is decoupled from the device's animation scale settings.

Pixel-Perfect Auto-Sizing: The widget calculates the exact pixel height of the text using TextPainter and uses it to constrain its own height, eliminating vertical overflow issues and providing clean integration into any layout.

🔧 Improvements & Fixes
Corrected the initial load logic to ensure the first text in the provided list always scrolls first (issue fixed by separating _startInitialScroll from_cycleNextText).

Implemented logic for accurate horizontal positioning and scrolling direction reversal when textDirection is set to TextDirection.rtl.

Added pauseDuration property to control the time between the end of one scroll and the start of the next.
