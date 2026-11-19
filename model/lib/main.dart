import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tm_classifier/screens/history_screen.dart';
import 'package:tm_classifier/screens/home_screen.dart';
import 'package:tm_classifier/screens/model_screen.dart';
import 'package:tm_classifier/screens/welcome_screen.dart';
import 'package:tm_classifier/services/classifier.dart';
import 'package:tm_classifier/services/history_item.dart';
import 'package:tm_classifier/services/image_sources.dart';
import 'package:tm_classifier/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TmClassifierApp());
}

class TmClassifierApp extends StatefulWidget {
  const TmClassifierApp({super.key});

  @override
  State<TmClassifierApp> createState() => _TmClassifierAppState();
}

class _TmClassifierAppState extends State<TmClassifierApp> {
  Classifier? _classifier;
  String? _initError;
  bool _started = false;
  final ImageSources _imageSources = ImageSources();
  final List<HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _initClassifier();
  }

  Future<void> _initClassifier() async {
    setState(() {
      _initError = null;
      _classifier = null;
    });

    try {
      final classifier = await Classifier.load();

      // Smoke test (T10): load sample asset and classify
      try {
        final byteData = await rootBundle.load('assets/model/sample.jpg');
        final sampleBytes = byteData.buffer.asUint8List();
        final predictions = classifier.classify(sampleBytes);
        debugPrint('--- SMOKE TEST: Classifier loaded successfully ---');
        double totalConfidence = 0;
        for (final p in predictions) {
          debugPrint('${p.label}: ${(p.confidence * 100).toStringAsFixed(2)}%');
          totalConfidence += p.confidence;
        }
        debugPrint('Confidence Sum: ${totalConfidence.toStringAsFixed(4)}');
      } catch (e) {
        debugPrint('Smoke test sample classification note: $e');
      }

      if (mounted) {
        setState(() {
          _classifier = classifier;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = 'Failed to load model or labels from assets: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teachable Classifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: !_started
          ? WelcomeScreen(
              classifier: _classifier,
              errorMessage: _initError,
              onGetStarted: () => setState(() => _started = true),
              onRetry: _initClassifier,
            )
          : MainNavigationScaffold(
              classifier: _classifier!,
              imageSources: _imageSources,
              history: _history,
              onNewClassification: (item) {
                setState(() {
                  _history.insert(0, item);
                });
              },
            ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final Classifier classifier;
  final ImageSources imageSources;
  final List<HistoryItem> history;
  final Function(HistoryItem) onNewClassification;

  const MainNavigationScaffold({
    super.key,
    required this.classifier,
    required this.imageSources,
    required this.history,
    required this.onNewClassification,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        classifier: widget.classifier,
        imageSources: widget.imageSources,
        history: widget.history,
        onNewClassification: widget.onNewClassification,
      ),
      HistoryScreen(
        history: widget.history,
      ),
      ModelScreen(
        classifier: widget.classifier,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.memory_outlined),
            selectedIcon: Icon(Icons.memory_rounded),
            label: 'Model',
          ),
        ],
      ),
    );
  }
}
