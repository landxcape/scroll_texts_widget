import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_texts_widget/scroll_texts_widget.dart';

void main() {
  group('ScrollTextsController', () {
    test('initial values default correctly', () {
      final controller = ScrollTextsController(
        initialScrollOffset: 50.0,
        initialTextIndex: 1,
      );
      expect(controller.offset, 50.0);
      expect(controller.currentTextIndex, 1);
      expect(controller.isPaused, isFalse);
    });

    test('pause, resume, and togglePause notify listeners', () {
      final controller = ScrollTextsController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.pause();
      expect(controller.isPaused, isTrue);
      expect(notifyCount, 1);

      controller.resume();
      expect(controller.isPaused, isFalse);
      expect(notifyCount, 2);

      controller.togglePause();
      expect(controller.isPaused, isTrue);
      expect(notifyCount, 3);
    });

    test('jumpTo updates offset and notifies listeners', () {
      final controller = ScrollTextsController();
      double notifiedOffset = 0.0;
      controller.addListener(() => notifiedOffset = controller.offset);

      controller.jumpTo(120.0);
      expect(controller.offset, 120.0);
      expect(notifiedOffset, 120.0);
    });

    test('jumpToText updates index and offset', () {
      final controller = ScrollTextsController();
      controller.jumpToText(3, offset: 40.0);
      expect(controller.currentTextIndex, 3);
      expect(controller.offset, 40.0);
    });

    test('calculates progress and tracks effectiveRenderMode', () {
      final controller = ScrollTextsController();
      expect(controller.progress, 0.0);
      expect(controller.effectiveRenderMode, ScrollTextRenderMode.cached);

      controller.updateState(
        offset: 250.0,
        textIndex: 0,
        isPaused: false,
        maxScrollExtent: 1000.0,
        effectiveRenderMode: ScrollTextRenderMode.streaming,
      );

      expect(controller.offset, 250.0);
      expect(controller.maxScrollExtent, 1000.0);
      expect(controller.progress, 0.25);
      expect(controller.effectiveRenderMode, ScrollTextRenderMode.streaming);
    });
  });
}
