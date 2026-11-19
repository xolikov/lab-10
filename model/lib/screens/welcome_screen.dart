import 'package:flutter/material.dart';
import 'package:tm_classifier/services/classifier.dart';

class WelcomeScreen extends StatelessWidget {
  final Classifier? classifier;
  final String? errorMessage;
  final VoidCallback onGetStarted;
  final VoidCallback onRetry;

  const WelcomeScreen({
    super.key,
    required this.classifier,
    required this.errorMessage,
    required this.onGetStarted,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.remove_red_eye_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Teachable Classifier',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Recognises 6 distinct hand and finger gestures directly on your device with high-accuracy TensorFlow Lite inference.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 1),
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Model Initialization Failed',
                        style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onErrorContainer),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onRetry,
                        child: const Text('Retry Loading'),
                      ),
                    ],
                  ),
                ),
              ] else if (classifier == null) ...[
                Column(
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading TensorFlow Lite model & labels...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Recognised Classes (${classifier!.labels.length}):',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: classifier!.labels.map((label) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          label.isNotEmpty ? label[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      label: Text(label),
                    );
                  }).toList(),
                ),
              ],
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: classifier != null ? onGetStarted : null,
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
