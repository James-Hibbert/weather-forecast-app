import 'dart:io';

class ImageClassifier {
  static Future<String?> classifyImage(File image) async {
    await Future.delayed(Duration(seconds: 1));
    return 'Sunny';
  }
}

