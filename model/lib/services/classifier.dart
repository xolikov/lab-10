import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  const Prediction(this.label, this.confidence);
  final String label;
  final double confidence; // 0.0 to 1.0
}

/// "0 1\n1 2\n" becomes ['1', '2']. Pure, so it is unit-testable.
List<String> parseLabels(String raw) => [
      for (final line in raw.split(RegExp(r'\r?\n')))
        if (line.trim().isNotEmpty) line.trim().replaceFirst(RegExp(r'^\d+\s*'), ''),
    ];

class Classifier {
  Classifier._(this._interpreter, this.labels);
  final Interpreter _interpreter;
  final List<String> labels;
  static const inputSize = 224;

  static Future<Classifier> load({
    String modelPath = 'assets/model/model_unquant.tflite',
    String labelsPath = 'assets/model/labels.txt',
  }) async {
    final interpreter = await Interpreter.fromAsset(modelPath);
    final labelsRaw = await rootBundle.loadString(labelsPath);
    final labels = parseLabels(labelsRaw);
    return Classifier._(interpreter, labels);
  }

  List<Prediction> classify(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Not a readable image');

    final square = img.copyResizeCropSquare(img.bakeOrientation(decoded), size: inputSize);

    // Shape: [1, 224, 224, 3]
    final input = [
      List.generate(inputSize, (y) => List.generate(inputSize, (x) {
            final p = square.getPixel(x, y);
            return [p.r / 127.5 - 1, p.g / 127.5 - 1, p.b / 127.5 - 1];
          })),
    ];

    // Shape: [1, classes]
    final output = [List<double>.filled(labels.length, 0)];
    _interpreter.run(input, output);

    final predictions = [
      for (var i = 0; i < labels.length; i++) Prediction(labels[i], output.first[i])
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));

    return predictions;
  }

  void close() => _interpreter.close();
}
