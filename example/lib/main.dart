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
            textStyle: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            scrollSpeed: 75.0, // 75 pixels per second
            pauseDuration: const Duration(seconds: 1),
            // Example of RTL usage
            // textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}
