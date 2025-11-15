import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only imports
import 'dart:html' as html show IFrameElement;
import 'dart:ui_web' as ui_web show platformViewRegistry;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Figma Design Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FigmaViewerPage(),
    );
  }
}

class FigmaViewerPage extends StatefulWidget {
  const FigmaViewerPage({super.key});

  @override
  State<FigmaViewerPage> createState() => _FigmaViewerPageState();
}

class _FigmaViewerPageState extends State<FigmaViewerPage> {
  static const String _iframeUrl =
      'https://embed.figma.com/proto/emcuuZR44uJrcJ6x2v3V8Z/Food-Delivery-App---Wolt---UI-Inspiration--Community-?page-id=2005%3A93&node-id=2052-7106&p=f&viewport=407%2C30%2C0.31&scaling=scale-down&content-scaling=fixed&starting-point-node-id=2052%3A7106&embed-host=share';
  
  String? _viewType;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Register the iframe for web
      _registerIframe();
    }
  }

  void _registerIframe() {
    // Create a unique view type for the iframe
    _viewType = 'figma-iframe-${DateTime.now().millisecondsSinceEpoch}';
    
    // Create iframe element
    html.IFrameElement iframe = html.IFrameElement()
      ..src = _iframeUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..allow = 'fullscreen';

    // Register the platform view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType!,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Figma Design Viewer'),
        ),
        body: const Center(
          child: Text(
            'This app is only available on web.\nPlease run it using "flutter run -d chrome"',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_viewType == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery App - Figma Design'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SizedBox(
                    width: 800,
                    height: 450,
                    child: HtmlElementView(
                      viewType: _viewType!,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Food Delivery App - Wolt UI Inspiration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Interactive Figma prototype embedded in Flutter',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
