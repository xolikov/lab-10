import 'dart:typed_data';
import 'package:tm_classifier/services/classifier.dart';

enum ImageSourceType { camera, gallery, download }

class HistoryItem {
  final Uint8List imageBytes;
  final List<Prediction> predictions;
  final ImageSourceType source;
  final DateTime timestamp;

  HistoryItem({
    required this.imageBytes,
    required this.predictions,
    required this.source,
    required this.timestamp,
  });

  Prediction get topPrediction => predictions.first;
}
