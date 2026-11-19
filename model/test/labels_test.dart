import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  group('parseLabels unit tests', () {
    test('normal case: 0 1\\n1 2\\n gives [1, 2]', () {
      const raw = '0 1\n1 2\n';
      final labels = parseLabels(raw);
      expect(labels, ['1', '2']);
    });

    test('awkward case: Windows line endings, trailing blanks, and spaces in label', () {
      const awkwardRaw = '0 Fist\r\n1 Thumb Up\r\n2 Peace sign\r\n\r\n';
      final labels = parseLabels(awkwardRaw);
      expect(labels, ['Fist', 'Thumb Up', 'Peace sign']);
    });

    test('handles full 6 finger gesture classes from labels.txt correctly', () {
      const raw = '0 1\n1 2\n2 3\n3 4\n4 5\n5 0\n';
      final labels = parseLabels(raw);
      expect(labels, ['1', '2', '3', '4', '5', '0']);
      expect(labels.length, 6);
    });
  });
}
