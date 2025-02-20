import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
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

class PhotoFileForSave {
  static const mime = 'image/png';
  final String titleAndExt;
  final Uint8List content;
  const PhotoFileForSave(this.titleAndExt, this.content);
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

  static Future<String> savePhotos(
      {required List<PhotoFileForSave> data,
      required String fileName,
      String? testFolderPath,
      String l10nText = 'Enregistrement des photos'}) async {
    String? initialDirectory =
        await getPathAndAvoidWebError(testFolderPath: testFolderPath);
    if (testFolderPath != null && testFolderPath.isNotEmpty) {
      // testing hack so that i do not need to press ok on dialog
      //final f = await File(fileName).;
      //return f.path;
      return ''; // * XXX do da test
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final outputFilePath = await FilePicker.platform.saveFile(
        //Custom extension filters are only allowed with FileType.custom
        //allowedExtensions: ['jpg', 'jpeg', 'png'],
        type: FileType.image,
        dialogTitle: l10nText,
        fileName: fileName,
        initialDirectory: testFolderPath ?? initialDirectory,
        lockParentWindow: true,
      );
      if (outputFilePath != null && outputFilePath.isNotEmpty) {
        if (Directory(outputFilePath).existsSync() == false) {
          Directory(outputFilePath).createSync();
        }

        for (final dd in data) {
          final path = join(outputFilePath, dd.titleAndExt);

          try {
            await File(path).writeAsBytes(dd.content.toList());
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        }
        return outputFilePath;
      } else {
        return '';
      }
    } else {
      if (Platform.isAndroid) {
        await MediaStore.ensureInitialized();

        final mediaStorePlugin = MediaStore();
        if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
          MediaStore.appFolder = "MediaStorePlugin";
          final saveInfo = await mediaStorePlugin.saveFile(
              tempFilePath: fileName,
              dirType: DirType.photo,
              dirName: DirType.photo.defaults);
          if (saveInfo != null && saveInfo.isSuccessful) {
            return saveInfo.uri.path;
          } else {
            return '';
          }
        } else {
          // Android without mediaStore
          DocumentFileSavePlus().saveMultipleFiles(
            dataList: data.map((e) => e.content).toList(),
            fileNameList: data.map((e) => e.titleAndExt).toList(),
            mimeTypeList: data.map((e) => PhotoFileForSave.mime).toList(),
          );
          final downloadDir = await getDownloadsDirectory();
          return downloadDir?.path ?? '';
        }
      } else {
        //  iOS
        DocumentFileSavePlus().saveMultipleFiles(
          dataList: data.map((e) => e.content).toList(),
          fileNameList: data.map((e) => e.titleAndExt).toList(),
          mimeTypeList: data.map((e) => PhotoFileForSave.mime).toList(),
        );
        final downloadDir = await getDownloadsDirectory();
        return downloadDir?.path ?? '';
      }
    }
  }

  static Future<String> saveCsv(
      {required String content,
      required String fileName,
      String? testFolderPath,
      String l10nText = 'Enregistrement du csv'}) async {
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
      final path =
          testFolderPath + Platform.pathSeparator + fileNameTimestamped;
      await File(path).writeAsString(content);
      return path;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final String? outputFilePath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: l10nText,
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
        await MediaStore.ensureInitialized();
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
  static Future<String> saveJson(
      {required String content,
      required String fileName,
      String? testFolderPath,
      String l10nText = 'Enregistrement du json'}) async {
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
      final path =
          testFolderPath + Platform.pathSeparator + fileNameTimestamped;
      await File(path).writeAsString(content);
      return path;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      /// This method is only available on desktop platforms (Linux, macOS & Linux)
      final String? outputFilePath = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10nText,
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
        await MediaStore.ensureInitialized();
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
