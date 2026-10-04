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
  TextDirection _textDirection = TextDirection.ltr;
  double _speed = 80.0;
  double _pauseSeconds = 1.0;
  bool _repeat = true;
  String _lastCompletedText = 'None yet';
  bool _pauseOnHover = true;
  bool _enableTapInspection = true;
  bool _enableGradientMask = false;

  final List<String> _englishTexts = [
    'Welcome to the highly efficient scroll_texts_widget package!',
    'Supports both pre-cached GPU clipping and Level 2 sliding window streaming.',
    'Programmatic control: play, pause, seek, jump to text, and inspect offsets in real-time.',
    'A very long announcement to showcase streaming: ' * 10,
  ];

  final List<String> _arabicTexts = [
    'مرحبا بكم في حزمة scroll_texts_widget العالية الكفاءة لنظام فلاتر!',
    'تدعم اتجاه النص من اليمين إلى اليسار والرسوم المتحركة المستقلة عن الأجهزة.',
    'نص طويل جداً لعرض تقنية النوافذ المنزلقة: ' * 6,
  ];

  List<String> get _currentTexts =>
      _textDirection == TextDirection.ltr ? _englishTexts : _arabicTexts;

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
            Builder(
              builder: (context) {
                Widget banner = ScrollTextsWidget(
                  texts: _currentTexts,
                  controller: _controller,
                  renderMode: _renderMode,
                  textDirection: _textDirection,
                  repeat: _repeat,
                  scrollSpeed: _speed,
                  pauseDuration: Duration(
                    milliseconds: (_pauseSeconds * 1000).round(),
                  ),
                  onTextCompleted: (index) {
                    setState(() {
                      _lastCompletedText = '#${index + 1}';
                    });
                  },
                  onScrollChanged: (offset, index) {
                    // Real-time position callback hook
                  },
                  textStyle: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                );

                if (_enableTapInspection) {
                  banner = GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final idx = _controller.currentTextIndex;
                      final text = _currentTexts.isNotEmpty &&
                              idx >= 0 &&
                              idx < _currentTexts.length
                          ? _currentTexts[idx]
                          : '';
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Tapped announcement #${idx + 1}: $text'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: banner,
                  );
                }

                if (_pauseOnHover) {
                  banner = MouseRegion(
                    cursor: _enableTapInspection
                        ? SystemMouseCursors.click
                        : MouseCursor.defer,
                    onEnter: (_) => _controller.pause(),
                    onExit: (_) => _controller.resume(),
                    child: banner,
                  );
                }

                if (_enableGradientMask) {
                  banner = ShaderMask(
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
                    child: banner,
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: banner,
                );
              },
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Position: ${_controller.offset.toStringAsFixed(1)} / ${_controller.maxScrollExtent.toStringAsFixed(1)} px (${(_controller.progress * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Active Text: #${_controller.currentTextIndex + 1} of ${_currentTexts.length} (${_currentTexts.isNotEmpty && _controller.currentTextIndex < _currentTexts.length ? _currentTexts[_controller.currentTextIndex].length : 0} chars)',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Render Mode: ${_renderMode == ScrollTextRenderMode.auto ? 'Auto ➔ ${_controller.effectiveRenderMode.name.toUpperCase()} (auto-selected)' : _renderMode.name.toUpperCase()}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: _renderMode == ScrollTextRenderMode.auto
                                    ? Colors.deepPurple
                                    : null,
                              ),
                            ),
                            Text(
                              'State: ${_controller.isPaused ? 'Paused ⏸️' : 'Scrolling ▶️'}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            Text(
                              'Last Completed: $_lastCompletedText',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Playback Controls',
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
                            builder: (context, _) =>
                                Text(_controller.isPaused ? 'Resume' : 'Pause'),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _controller.jumpTo(0.0),
                          child: const Text('Reset (0px)'),
                        ),
                        OutlinedButton(
                          onPressed: () => _controller.jumpTo(250.0),
                          child: const Text('Jump 250px'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            final nextIndex =
                                (_controller.currentTextIndex + 1) %
                                _currentTexts.length;
                            _controller.jumpToText(nextIndex);
                          },
                          child: const Text('Next Text'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Text('Scroll Speed: ${_speed.toStringAsFixed(0)} px/s'),
                        Expanded(
                          child: Slider(
                            value: _speed,
                            min: 20.0,
                            max: 200.0,
                            divisions: 18,
                            label: '${_speed.toStringAsFixed(0)} px/s',
                            onChanged: (val) {
                              setState(() {
                                _speed = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Pause Gap: ${_pauseSeconds.toStringAsFixed(1)} s',
                        ),
                        Expanded(
                          child: Slider(
                            value: _pauseSeconds,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            label: '${_pauseSeconds.toStringAsFixed(1)} s',
                            onChanged: (val) {
                              setState(() {
                                _pauseSeconds = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Render Mode & Direction',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<ScrollTextRenderMode>(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<TextDirection>(
                            segments: const [
                              ButtonSegment(
                                value: TextDirection.ltr,
                                label: Text('LTR (Left-to-Right)'),
                              ),
                              ButtonSegment(
                                value: TextDirection.rtl,
                                label: Text('RTL (Right-to-Left)'),
                              ),
                            ],
                            selected: {_textDirection},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _textDirection = selected.first;
                                _controller.jumpToText(0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('Continuous Looping (repeat)'),
                      subtitle: const Text(
                        'Loops back to start after the last text completes',
                      ),
                      value: _repeat,
                      onChanged: (val) {
                        setState(() {
                          _repeat = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Interactive Recipes (Composition)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Pause on Hover (MouseRegion)'),
                      subtitle: const Text(
                        'Hover mouse over marquee on Desktop/Web to pause',
                      ),
                      value: _pauseOnHover,
                      onChanged: (val) {
                        setState(() {
                          _pauseOnHover = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Tap to Inspect (GestureDetector)'),
                      subtitle: const Text(
                        'Tap the marquee to inspect active announcement in SnackBar',
                      ),
                      value: _enableTapInspection,
                      onChanged: (val) {
                        setState(() {
                          _enableTapInspection = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Soft Edge Fade (ShaderMask)'),
                      subtitle: const Text(
                        'Applies gradient mask to fade text as it enters and exits edges',
                      ),
                      value: _enableGradientMask,
                      onChanged: (val) {
                        setState(() {
                          _enableGradientMask = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
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
