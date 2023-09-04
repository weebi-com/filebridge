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
  static Future<String?> avoidWebError({String? testFolderPath}) async {
    if (kIsWeb == false) {
      if (testFolderPath == null || testFolderPath.isEmpty) {
        return (await getApplicationDocumentsDirectory()).path;
      }
    }
    return null;
  }

  static Future<String?> savePhoto(
      {required String content,
      required String fileName,
      String? testFolderPath}) async {
    String? initialDirectory =
        await avoidWebError(testFolderPath: testFolderPath);

    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      final now = DateTime.now();
      // testing hack so that i do not need to press ok on dialog
      final f = await File('${now.hour}h${now.minute}m${now.second}s_$fileName')
          .writeAsString(content);
      return f.path;
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
    fileName = '$fileName.csv';
    final now = DateTime.now();
    String? initialDirectory =
        await avoidWebError(testFolderPath: testFolderPath);

    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      return await File('${now.hour}h${now.minute}m${now.second}s_$fileName')
          .writeAsString(content);
    }
    final String? outputFile = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Enregistrement du csv',
      fileName: '${now.hour}h${now.minute}m${now.second}s_$fileName',
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
    fileName = '$fileName.json';
    final now = DateTime.now();
    String? initialDirectory =
        await avoidWebError(testFolderPath: testFolderPath);

    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      return await File('${now.hour}h${now.minute}m${now.second}s_$fileName')
          .writeAsString(content);
    }
    final String? outputFile = await FilePicker.platform.saveFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Enregistrement du json',
      fileName: '${now.hour}h${now.minute}m${now.second}s_$fileName',
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
