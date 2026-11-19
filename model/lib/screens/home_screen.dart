import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tm_classifier/screens/result_screen.dart';
import 'package:tm_classifier/services/classifier.dart';
import 'package:tm_classifier/services/history_item.dart';
import 'package:tm_classifier/services/image_sources.dart';

class HomeScreen extends StatefulWidget {
  final Classifier classifier;
  final ImageSources imageSources;
  final List<HistoryItem> history;
  final Function(HistoryItem) onNewClassification;

  const HomeScreen({
    super.key,
    required this.classifier,
    required this.imageSources,
    required this.history,
    required this.onNewClassification,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProcessing = false;

  Future<void> _handleBytes(Uint8List bytes, ImageSourceType source) async {
    setState(() => _isProcessing = true);
    try {
      final predictions = widget.classifier.classify(bytes);
      final item = HistoryItem(
        imageBytes: bytes,
        predictions: predictions,
        source: source,
        timestamp: DateTime.now(),
      );
      widget.onNewClassification(item);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(historyItem: item),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Classification Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickCamera() async {
    try {
      final bytes = await widget.imageSources.fromCamera();
      if (bytes != null) {
        await _handleBytes(bytes, ImageSourceType.camera);
      }
    } catch (e) {
      _showErrorDialog('Camera Error', e.toString());
    }
  }

  Future<void> _pickGallery() async {
    try {
      final bytes = await widget.imageSources.fromGallery();
      if (bytes != null) {
        await _handleBytes(bytes, ImageSourceType.gallery);
      }
    } catch (e) {
      _showErrorDialog('Gallery Error', e.toString());
    }
  }

  Future<void> _showUrlDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Image'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter a direct web URL to an image file (e.g. JPG, PNG):'),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/photo.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'URL cannot be empty';
                  if (!val.trim().startsWith('http://') && !val.trim().startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() => _isProcessing = true);
      try {
        final bytes = await widget.imageSources.fromUrl(url);
        await _handleBytes(bytes, ImageSourceType.download);
      } catch (e) {
        _showErrorDialog('Download Error', e.toString());
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentItem = widget.history.isNotEmpty ? widget.history.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classifier'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Classify New Image',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select an input source to run offline ML inference',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),

              // Action 1: Camera
              _buildActionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Take a Photo',
                subtitle: 'Capture directly using phone camera',
                color: theme.colorScheme.primary,
                onTap: _isProcessing ? null : _pickCamera,
              ),
              const SizedBox(height: 12),

              // Action 2: Gallery
              _buildActionCard(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                subtitle: 'Select saved photos or screenshots',
                color: const Color(0xFF8B5CF6),
                onTap: _isProcessing ? null : _pickGallery,
              ),
              const SizedBox(height: 12),

              // Action 3: URL
              _buildActionCard(
                icon: Icons.cloud_download_rounded,
                title: 'Download an Image',
                subtitle: 'Fetch from web address via HTTP',
                color: const Color(0xFF10B981),
                onTap: _isProcessing ? null : _showUrlDialog,
              ),
              const SizedBox(height: 28),

              // Most recent result
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Most Recent Result',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (recentItem != null)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResultScreen(historyItem: recentItem),
                          ),
                        );
                      },
                      child: const Text('View Full'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (recentItem == null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.image_outlined, size: 40, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'No classifications yet this session',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(historyItem: recentItem),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              recentItem.imageBytes,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recentItem.topPrediction.label,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Confidence: ${(recentItem.topPrediction.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Classifying image...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
