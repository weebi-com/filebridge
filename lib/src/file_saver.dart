import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileSaver {
  static Future<File> makeFileAndWriteAsStringAsync(
      String content, String folder, String fileName) async {
    final file = File('$folder/$fileName');
    final fileWritten = await file.writeAsString(content);
    return fileWritten;
  }
}

abstract class FileSaverV2 {
  static Future<String?> savePhoto(
      {required String content,
      required String fileName,
      String? testFolderPath}) async {
    String? initialDirectory;
    if (!kIsWeb) {
      initialDirectory = (await getApplicationDocumentsDirectory()).path;
    }
    return await FilePicker.platform.saveFile(
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      dialogTitle: 'Enregistrement de la photo',
      fileName: fileName,
      initialDirectory: testFolderPath ?? initialDirectory,
      lockParentWindow: true,
    );
  }

  static Future<File> saveCsv(
      {required String content,
      required String fileName,
      String? testFolderPath}) async {
    final now = DateTime.now();
    String? initialDirectory;
    if (!kIsWeb) {
      initialDirectory = (await getApplicationDocumentsDirectory()).path;
    }
    final String? outputFile = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Enregistrement du csv',
      fileName: '${fileName}_${now.hour}h${now.minute}m${now.second}s.csv',
      initialDirectory: testFolderPath ?? initialDirectory,
      lockParentWindow: true,
    );
    if (outputFile != null) {
      return await File(outputFile).writeAsString(content);
    } else {
      return File('');
    }
  }

  static Future<File> saveJson(
      {required String content,
      required String fileName,
      String? testFolderPath}) async {
    final now = DateTime.now();
    String? initialDirectory;
    if (!kIsWeb) {
      initialDirectory = (await getApplicationDocumentsDirectory()).path;
    }
    final String? outputFile = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Enregistrement du json',
      fileName: '${fileName}_${now.hour}h${now.minute}m${now.second}s.json',
      initialDirectory: testFolderPath ?? initialDirectory,
      lockParentWindow: true,
    );
    if (outputFile != null) {
      return await File(outputFile).writeAsString(content);
    } else {
      return File('');
    }
  }
}
