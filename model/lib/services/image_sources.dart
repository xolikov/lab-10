import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageSources {
  final _picker = ImagePicker();

  Future<Uint8List?> fromCamera() async {
    final shot = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (shot == null) return null;
    return await shot.readAsBytes();
  }

  Future<Uint8List?> fromGallery() async {
    final shot = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (shot == null) return null;
    return await shot.readAsBytes();
  }

  Future<Uint8List> fromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      throw const FormatException('Invalid image URL. Must start with http:// or https://');
    }

    final response = await http.get(uri).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw Exception('Connection timed out while downloading the image.');
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Server returned error HTTP ${response.statusCode}');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().startsWith('image/')) {
      throw const FormatException('The provided URL returned a webpage or non-image content.');
    }

    return response.bodyBytes;
  }
}
