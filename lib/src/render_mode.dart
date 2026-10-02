/// Defines how [ScrollTextsWidget] lays out and renders scrolling text.
enum ScrollTextRenderMode {
  /// Automatically selects [cached] for short/medium texts (< 300 characters)
  /// and [streaming] for long texts to optimize memory and performance.
  auto,

  /// Lays out the text once and uses hardware-accelerated GPU clipping.
  /// Offers 100% typographic fidelity (BiDi, complex scripts, kerning).
  cached,

  /// Uses a sliding window that measures and paints only words/chunks
  /// physically visible inside the widget's viewport.
  /// Provides O(1) memory and prevents UI freezes on massive strings.
  streaming,
}
