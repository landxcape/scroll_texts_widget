import 'package:flutter/material.dart';
import 'package:scroll_texts_widget/scroll_texts_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Texts Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyMarqueeApp(),
    );
  }
}

class MyMarqueeApp extends StatefulWidget {
  const MyMarqueeApp({super.key});

  @override
  State<MyMarqueeApp> createState() => _MyMarqueeAppState();
}

class _MyMarqueeAppState extends State<MyMarqueeApp> {
  final ScrollTextsController _controller = ScrollTextsController();
  ScrollTextRenderMode _renderMode = ScrollTextRenderMode.auto;

  final List<String> _texts = [
    'Welcome to the highly efficient scroll_texts_widget package!',
    'Supports both pre-cached GPU clipping and Level 2 sliding window streaming.',
    'Programmatic control: play, pause, seek, jump to text, and inspect offsets in real-time.',
    'A very long announcement to showcase streaming: ' * 10,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Efficient Marquee Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Live Marquee Banner',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: ScrollTextsWidget(
                texts: _texts,
                controller: _controller,
                renderMode: _renderMode,
                scrollSpeed: 80.0,
                pauseDuration: const Duration(seconds: 1),
                textStyle: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Controller & Position Monitor',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offset: ${_controller.offset.toStringAsFixed(1)} px',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Active Text: #${_controller.currentTextIndex + 1} of ${_texts.length}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'State: ${_controller.isPaused ? 'Paused ⏸️' : 'Scrolling ▶️'}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Controls',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _controller.togglePause(),
                          icon: ListenableBuilder(
                            listenable: _controller,
                            builder: (context, _) => Icon(
                              _controller.isPaused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                            ),
                          ),
                          label: ListenableBuilder(
                            listenable: _controller,
                            builder: (context, _) => Text(
                              _controller.isPaused ? 'Resume' : 'Pause',
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _controller.jumpTo(0.0),
                          child: const Text('Reset Offset (0px)'),
                        ),
                        OutlinedButton(
                          onPressed: () => _controller.jumpTo(250.0),
                          child: const Text('Jump to 250px'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            final nextIndex =
                                (_controller.currentTextIndex + 1) %
                                    _texts.length;
                            _controller.jumpToText(nextIndex);
                          },
                          child: const Text('Next Text'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Render Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ScrollTextRenderMode>(
                      segments: const [
                        ButtonSegment(
                          value: ScrollTextRenderMode.auto,
                          label: Text('Auto'),
                        ),
                        ButtonSegment(
                          value: ScrollTextRenderMode.cached,
                          label: Text('Cached'),
                        ),
                        ButtonSegment(
                          value: ScrollTextRenderMode.streaming,
                          label: Text('Streaming'),
                        ),
                      ],
                      selected: {_renderMode},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _renderMode = selected.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
