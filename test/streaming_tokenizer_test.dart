import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_texts_widget/src/streaming_tokenizer.dart';

void main() {
  group('StreamingTokenizer', () {
    test('tokenizes standard English sentences preserving spaces', () {
      final chunks = StreamingTokenizer.tokenize('The quick brown fox');
      expect(chunks, equals(['The ', 'quick ', 'brown ', 'fox']));
    });

    test('tokenizes unbroken long words/URLs by maxChunkChars', () {
      final longWord = 'A' * 45;
      final chunks = StreamingTokenizer.tokenize(longWord, maxChunkChars: 20);
      expect(chunks.length, 3);
      expect(chunks[0], 'A' * 20);
      expect(chunks[1], 'A' * 20);
      expect(chunks[2], 'A' * 5);
      expect(chunks.join(''), longWord);
    });

    test('tokenizes Chinese/CJK characters smoothly without data loss', () {
      const cjk = '欢迎来到Flutter滚动文字组件世界';
      final chunks = StreamingTokenizer.tokenize(cjk, maxChunkChars: 8);
      expect(chunks.join(''), cjk);
      expect(chunks.every((c) => c.length <= 8), isTrue);
    });

    test('handles empty and whitespace strings gracefully', () {
      expect(StreamingTokenizer.tokenize(''), isEmpty);
      expect(StreamingTokenizer.tokenize('   '), equals(['   ']));
    });
  });
}
