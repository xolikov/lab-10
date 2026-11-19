import 'package:flutter/material.dart';
import 'package:tm_classifier/services/history_item.dart';

class ResultScreen extends StatelessWidget {
  final HistoryItem historyItem;

  const ResultScreen({super.key, required this.historyItem});

  String _sourceName(ImageSourceType source) {
    switch (source) {
      case ImageSourceType.camera:
        return 'Camera';
      case ImageSourceType.gallery:
        return 'Gallery';
      case ImageSourceType.download:
        return 'Downloaded URL';
    }
  }

  IconData _sourceIcon(ImageSourceType source) {
    switch (source) {
      case ImageSourceType.camera:
        return Icons.camera_alt_rounded;
      case ImageSourceType.gallery:
        return Icons.photo_library_rounded;
      case ImageSourceType.download:
        return Icons.cloud_download_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Source badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_sourceIcon(historyItem.source), size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      _sourceName(historyItem.source),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Classified image: horizontally centred, uncropped (contain), <= half screen
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.42,
                maxWidth: size.width * 0.88,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  historyItem.imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Label results header
          Text(
            'Predictions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Label rows
          ...historyItem.predictions.asMap().entries.map((entry) {
            final index = entry.key;
            final prediction = entry.value;
            final isTop = index == 0;
            final percentageStr = (prediction.confidence * 100).toStringAsFixed(1);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isTop ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTop ? theme.colorScheme.primary : const Color(0xFFE2E8F0),
                  width: isTop ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        prediction.label,
                        style: TextStyle(
                          fontSize: isTop ? 16 : 14,
                          fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                          color: isTop ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$percentageStr %',
                        style: TextStyle(
                          fontSize: isTop ? 16 : 14,
                          fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                          color: isTop ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: prediction.confidence.clamp(0.0, 1.0),
                      minHeight: isTop ? 8 : 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTop ? theme.colorScheme.primary : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
