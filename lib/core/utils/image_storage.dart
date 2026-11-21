import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorage {
  ImageStorage._();

  static Future<String> saveImage(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'images'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final ext = p.extension(source.path).isNotEmpty ? p.extension(source.path) : '.jpg';
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}$ext';
    final saved = await source.copy(p.join(imagesDir.path, fileName));
    return saved.path;
  }
}
