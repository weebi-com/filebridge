// Dart imports:
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File, Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
// Package imports:
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

const excelTypeGroup =
    XTypeGroup(label: 'excel', extensions: ['xls', 'xlsx', 'xlsm']);
const csvTypeGroup =
    XTypeGroup(label: 'csv', extensions: ['csv', 'tsv', 'txt']);

const photoTypeGroup =
    XTypeGroup(label: 'photo', extensions: ['jpg', 'jpeg', 'png']);

abstract class FileLoaderMonolith {
  /// Loads a photo from user selection.
  /// 
  /// On Android: Uses image_picker with Photo Picker (no permissions required).
  /// On iOS and Desktop: Uses file_picker as before.
  /// 
  /// Returns an empty File if user cancels or an error occurs.
  static Future<File> loadPhotoFromUserPick({String titlel10n = ''}) async {
    // Use image_picker on Android to avoid READ_MEDIA_IMAGES permission requirement
    // This uses the Android Photo Picker which doesn't need permissions
    if (kIsWeb == false && Platform.isAndroid) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          // Convert XFile to File to maintain return type compatibility
          return File(pickedFile.path);
        } else {
          // User canceled the picker
          return File('');
        }
      } catch (e) {
        // Log error and return empty File
        print('Error picking image with image_picker: $e');
        return File('');
      }
    } else {
      // iOS and Desktop: continue using file_picker
      final initialDirectory = (await getApplicationDocumentsDirectory()).path;

      try {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowCompression: true,
            compressionQuality: 30,
            type: FileType
                .custom, // https://github.com/miguelpruivo/flutter_file_picker/issues/1534#issuecomment-2410581445
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ], // Custom extension filters are only allowed with FileType.custom
            dialogTitle: titlel10n.isNotEmpty ? titlel10n : 'Choix de la photo',
            initialDirectory: initialDirectory,
            lockParentWindow: true,
            allowMultiple: false);
        return File(result?.files.first.path ?? '');
      } on PlatformException catch (e) {
        print(e);
        return File('');
      }
    }
  }

  static Future<Directory> loadFolderFromUserPick(
      {String titlel10n = ''}) async {
    final initialDirectory = (await getApplicationDocumentsDirectory()).path;

    try {
      final String? result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: titlel10n.isNotEmpty
            ? titlel10n
            : 'Choix du dossier contenant les photos',
        initialDirectory: initialDirectory,
        lockParentWindow: true,
      );
      return Directory(result ?? '');
    } on PlatformException catch (e) {
      print(e);
      return Directory('');
    }
  }

  static List<List<dynamic>> decodeExcelFilePath(String filePath) {
    if (filePath.isEmpty) {
      return [];
    } else {
      try {
        final bytes = File(filePath).readAsBytesSync();
        final decoder = SpreadsheetDecoder.decodeBytes(bytes);
        final table = decoder.tables.values.first; // first tab in file
        return table.rows;
      } on PlatformException catch (e) {
        print(e);
        return [];
      }
    }
  }

// used ?
  static Future<dynamic> decodeJsonFilePath(String filePath) async {
    if (filePath.isEmpty) {
      return [];
    } else {
      try {
        final loadedJsonFile = await File(filePath).readAsString();
        return jsonDecode(loadedJsonFile);
      } on PlatformException catch (e) {
        print(e);
        return null;
      }
    }
  }

  static Future<File> loadExcelFileFromUserPick() async {
    if (!kIsWeb) {
      // legacy
      //  use file_picker for iOS/Android and  file_selector for web/desktop.
      if (Platform.isMacOS || Platform.isWindows) {
        final initialDirectory =
            (await getApplicationDocumentsDirectory()).path;
        try {
          final result = await openFile(
              initialDirectory: initialDirectory,
              acceptedTypeGroups: [excelTypeGroup]);
          return File(result?.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      } else {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowCompression: false,
              type: FileType.custom,
              allowedExtensions: ['xls', 'xlsx', 'xlsm']);
          return File(result?.files.first.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      }
    } else {
      print('web not supported yet');
      return File('');
    }
  }

  static Future<File> loadCsvFileFromUserPick() async {
    if (!kIsWeb) {
      // legacy
      //  use file_picker for iOS/Android and  file_selector for web/desktop.
      if (Platform.isMacOS || Platform.isWindows) {
        final initialDirectory =
            (await getApplicationDocumentsDirectory()).path;
        try {
          final result = await openFile(
              initialDirectory: initialDirectory,
              acceptedTypeGroups: [csvTypeGroup]);
          return File(result?.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      } else {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowCompression: false,
              type: FileType.custom,
              allowedExtensions: ['csv', 'tsv', 'txt']);
          return File(result?.files.first.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      }
    } else {
      print('web not supported yet');
      return File('');
    }
  }

  static Future<File> loadJsonFileFromUserPick() async {
    if (!kIsWeb) {
      // legacy
      //  use file_picker for iOS/Android and  file_selector for web/desktop.
      if (Platform.isMacOS || Platform.isWindows) {
        final initialDirectory =
            (await getApplicationDocumentsDirectory()).path;
        try {
          final result = await openFile(
              initialDirectory: initialDirectory,
              acceptedTypeGroups: [
                const XTypeGroup(label: 'json', extensions: ['json'])
              ]);
          return File(result?.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      } else {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowCompression: false,
              type: FileType.custom,
              allowedExtensions: ['json']);
          return File(result?.files.first.path ?? '');
        } on PlatformException catch (e) {
          print(e);
          return File('');
        }
      }
    } else {
      print('web not supported yet');
      return File('');
    }
  }
}
