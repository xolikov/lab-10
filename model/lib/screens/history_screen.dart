import 'package:flutter/material.dart';
import 'package:tm_classifier/screens/result_screen.dart';
import 'package:tm_classifier/services/history_item.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryItem> history;

  const HistoryScreen({super.key, required this.history});

  String _formatSource(ImageSourceType source) {
    switch (source) {
      case ImageSourceType.camera:
        return 'Camera';
      case ImageSourceType.gallery:
        return 'Gallery';
      case ImageSourceType.download:
        return 'URL Download';
    }
  }

  IconData _formatSourceIcon(ImageSourceType source) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history_rounded, size: 36, color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No classifications yet',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Images you classify will appear here in reverse chronological order.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final item = history[index];
                final topPred = item.topPrediction;
                final percentage = (topPred.confidence * 100).toStringAsFixed(1);

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(historyItem: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              item.imageBytes,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topPred.label,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(_formatSourceIcon(item.source), size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatSource(item.source),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$percentage %',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
