import 'package:flutter/material.dart';
import 'package:tm_classifier/services/classifier.dart';

class ModelScreen extends StatelessWidget {
  final Classifier classifier;

  const ModelScreen({super.key, required this.classifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Model Spec Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.memory_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'TensorFlow Lite Spec',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildSpecRow('Model Asset', 'model_unquant.tflite'),
                  _buildSpecRow('Labels Asset', 'labels.txt'),
                  _buildSpecRow('Input Tensor Shape', '[1, 224, 224, 3]'),
                  _buildSpecRow('Input Data Type', 'Float32 ([-1.0, 1.0])'),
                  _buildSpecRow('Number of Classes', '${classifier.labels.length} classes'),
                  _buildSpecRow('Inference Engine', 'tflite_flutter (On-Device)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Trained Classes Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configured Class Labels',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...classifier.labels.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${entry.key}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Attribution & Design Credit Card (T14 requirement)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Design & Community Credits',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'UI design adapted from open-source Figma Community template: "Mobile Clean UI Kit & App Design System" by @minimalui under Creative Commons Attribution (CC BY 4.0).',
                    style: TextStyle(height: 1.4, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
