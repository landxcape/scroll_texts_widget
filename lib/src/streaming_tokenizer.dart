/// Utility that breaks strings into renderable tokens for streaming window layout.
class StreamingTokenizer {
  /// Splits [input] into a list of chunks.
  ///
  /// Words followed by spaces are kept intact (e.g. `'hello '`).
  /// If a single token has no spaces or exceeds [maxChunkChars], it is
  /// subdivided into chunks of up to [maxChunkChars] characters.
  static List<String> tokenize(String input, {int maxChunkChars = 20}) {
    if (input.isEmpty) return const [];

    final tokens = <String>[];
    final regex = RegExp(r'(\S+\s*)');
    final matches = regex.allMatches(input);

    if (matches.isEmpty) {
      tokens.add(input);
      return tokens;
    }

    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        tokens.add(input.substring(lastEnd, match.start));
      }
      final word = match.group(0)!;
      if (word.length > maxChunkChars) {
        for (int i = 0; i < word.length; i += maxChunkChars) {
          final end = (i + maxChunkChars < word.length)
              ? i + maxChunkChars
              : word.length;
          tokens.add(word.substring(i, end));
        }
      } else {
        tokens.add(word);
      }
      lastEnd = match.end;
    }

    if (lastEnd < input.length) {
      tokens.add(input.substring(lastEnd));
    }

    return tokens;
  }
}
