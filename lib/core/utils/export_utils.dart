import 'dart:io';
import 'dart:typed_data';
import 'dart:math'; // Import dart:math untuk log()

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportUtils {
  static Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  static Future<File> saveBytesToFile(List<int> bytes, String fileName) async {
    final path = await getExportDirectory();
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> openFile(File file) async {
    await OpenFile.open(file.path);
  }

  static String formatBytes(int bytes) { // Diubah dari Future<String> ke String
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor(); // Perbaiki penggunaan log()
    return "${(bytes / 1024.pow(i)).toStringAsFixed(2)} ${suffixes[i]}";
  }

  static Future<Uint8List> loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

extension DoubleExtension on num {
  double pow(int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= toDouble();
    }
    return result;
  }
}