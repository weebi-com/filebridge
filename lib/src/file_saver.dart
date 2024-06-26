import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';

class FileSaver {
  static Future<File> makeFileAndWriteAsStringAsync(
      String content, String folder, String fileName) async {
    final file = File('$folder/$fileName');
    final fileWritten = await file.writeAsString(content);
    return fileWritten;
  }
}

abstract class FileSaverV2 {
  static Future<String?> getPathAndAvoidWebError(
      {String? testFolderPath}) async {
    if (kIsWeb == false) {
      if (Platform.isAndroid) {
        return (await getApplicationSupportDirectory()).path;
      }
      if (testFolderPath == null || testFolderPath.isEmpty) {
        return (await getApplicationDocumentsDirectory()).path;
      }
    }
    return null;
  }

  static Future<String?> savePhoto({
    required String content,
    required String fileName,
    String? testFolderPath,
  }) async {
    String? initialDirectory =
        await getPathAndAvoidWebError(testFolderPath: testFolderPath);

    final now = DateTime.now();
    final fileNameTimestamped =
        '${now.hour}h${now.minute}m${now.second}s_$fileName.png';

    final photo = utf8.encode(content);
    final Uint8List photo1 = Uint8List.fromList(photo);
    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      final f = await File(fileNameTimestamped).writeAsBytes(photo1);
      return f.path;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final outputFilePath = await FilePicker.platform.saveFile(
        type: FileType.image,
        //allowedExtensions: ['jpg', 'jpeg', 'png'], // Custom extension filters are only allowed with FileType.custom
        dialogTitle: 'Enregistrement de la photo',
        fileName: fileName,
        initialDirectory: testFolderPath ?? initialDirectory,
        lockParentWindow: true,
      );
      if (outputFilePath != null && outputFilePath.isNotEmpty) {
        final temp = await File(outputFilePath).writeAsBytes(photo1);
        return temp.path;
      } else {
        return '';
      }
    } else {
      if (Platform.isAndroid) {
        final mediaStorePlugin = MediaStore();
        if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
          MediaStore.appFolder = "MediaStorePlugin";
          final saveInfo = await mediaStorePlugin.saveFile(
              tempFilePath: fileNameTimestamped,
              dirType: DirType.photo,
              dirName: DirType.photo.defaults);
          if (saveInfo != null && saveInfo.isSuccessful) {
            return saveInfo.uri.path;
          } else {
            return '';
          }
        } else {
          // Android without mediaStore
          DocumentFileSavePlus()
              .saveFile(photo1, fileNameTimestamped, "image/png");
          return fileNameTimestamped;
        }
      } else {
        //  iOS
        DocumentFileSavePlus()
            .saveFile(photo1, fileNameTimestamped, "image/png");
        return fileNameTimestamped;
      }
    }
  }

  static Future<String> saveCsv({
    required String content,
    required String fileName,
    String? testFolderPath,
  }) async {
    if (fileName.split('.').last != 'csv') {
      fileName = '$fileName.csv';
    }

    final now = DateTime.now();
    String? initialDirectory =
        await getPathAndAvoidWebError(testFolderPath: testFolderPath);

    final fileNameTimestamped =
        '${now.hour}h${now.minute}m${now.second}s_$fileName';
    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      await File(fileNameTimestamped).writeAsString(content);
      return fileNameTimestamped;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final String? outputFilePath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Enregistrement du csv',
        fileName: '${now.hour}h${now.minute}m${now.second}s_$fileName',
        initialDirectory: testFolderPath ?? initialDirectory,
        lockParentWindow: true,
      );
      if (outputFilePath != null && outputFilePath.isNotEmpty) {
        final temp =
            await File(outputFilePath).writeAsString(content.toString());
        return temp.path;
      } else {
        return '';
      }
    } else {
      if (Platform.isAndroid) {
        final mediaStorePlugin = MediaStore();
        if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
          MediaStore.appFolder = "MediaStorePlugin";
          final saveInfo = await mediaStorePlugin.saveFile(
              tempFilePath: fileNameTimestamped,
              dirType: DirType.download,
              dirName: DirType.download.defaults);
          if (saveInfo != null && saveInfo.isSuccessful) {
            return saveInfo.uri.path;
          } else {
            return '';
          }
        } else {
          // Android without mediaStore
          final textBytes = utf8.encode(content);
          final Uint8List textBytes1 = Uint8List.fromList(textBytes);
          DocumentFileSavePlus()
              .saveFile(textBytes1, fileNameTimestamped, "text/plain");
          return fileNameTimestamped;
        }
      } else {
        //  iOS
        final textBytes = utf8.encode(content);
        final Uint8List textBytes1 = Uint8List.fromList(textBytes);
        DocumentFileSavePlus()
            .saveFile(textBytes1, fileNameTimestamped, "text/plain");
        return fileNameTimestamped;
      }
    }
  }

// if(Platform.isMacOS){
//TODO in macos remove volume/os from return path
  // substring
// }
  static Future<String> saveJson({
    required String content,
    required String fileName,
    String? testFolderPath,
  }) async {
    if (fileName.split('.').last != 'json') {
      fileName = '$fileName.json';
    }
    final now = DateTime.now();
    String? initialDirectory =
        await getPathAndAvoidWebError(testFolderPath: testFolderPath);

    final fileNameTimestamped =
        '${now.hour}h${now.minute}m${now.second}s_$fileName';
    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      await File(fileNameTimestamped).writeAsString(content);
      return fileNameTimestamped;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      /// This method is only available on desktop platforms (Linux, macOS & Linux)
      final String? outputFilePath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Enregistrement du json',
        fileName: fileNameTimestamped,
        initialDirectory: testFolderPath ?? initialDirectory,
        lockParentWindow: true,
      );
      if (outputFilePath != null && outputFilePath.isNotEmpty) {
        final temp =
            await File(outputFilePath).writeAsString(content.toString());
        return temp.path;
      } else {
        return '';
      }
    } else {
      if (Platform.isAndroid) {
        final mediaStorePlugin = MediaStore();
        if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
          MediaStore.appFolder = "MediaStorePlugin";
          final saveInfo = await mediaStorePlugin.saveFile(
              tempFilePath: fileNameTimestamped,
              dirType: DirType.download,
              dirName: DirType.download.defaults);
          if (saveInfo != null && saveInfo.isSuccessful) {
            return saveInfo.uri.path;
          } else {
            return '';
          }
        } else {
          // Android without mediaStore
          final textBytes = utf8.encode(content);
          final Uint8List textBytes1 = Uint8List.fromList(textBytes);
          DocumentFileSavePlus()
              .saveFile(textBytes1, fileNameTimestamped, "text/plain");
          return fileNameTimestamped; // probably wrong, user hint only
        }
      } else {
        // iOS
        final textBytes = utf8.encode(content);
        final Uint8List textBytes1 = Uint8List.fromList(textBytes);
        DocumentFileSavePlus()
            .saveFile(textBytes1, fileNameTimestamped, "text/plain");
        return fileNameTimestamped; // probably wrong, user hint only
      }
    }
  }
}
