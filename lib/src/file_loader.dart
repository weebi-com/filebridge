// Dart imports:
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, File, Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
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
  static Future<File> loadPhotoFromUserPick({String titlel10n = ''}) async {
    final initialDirectory = (await getApplicationDocumentsDirectory()).path;
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowCompression: (kIsWeb == false && Platform.isAndroid)
            ? false
            : true, // otherwise will crash on android 9
        compressionQuality: (kIsWeb == false && Platform.isAndroid) ? 0 : 30,
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
  }

  static Future<Directory> loadFolderFromUserPick(
      {String titlel10n = ''}) async {
    final initialDirectory = (await getApplicationDocumentsDirectory()).path;
    final String? result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: titlel10n.isNotEmpty
          ? titlel10n
          : 'Choix du dossier contenant les photos',
      initialDirectory: initialDirectory,
      lockParentWindow: true,
    );
    return Directory(result ?? '');
  }

  static Future<List<List<dynamic>>> decodeExcelFilePath(
      String filePath) async {
    if (filePath.isEmpty) {
      return [];
    } else {
      final bytes = File(filePath).readAsBytesSync();
      final decoder = SpreadsheetDecoder.decodeBytes(bytes);
      final table = decoder.tables.values.first; // first tab in file
      return table.rows;
    }
  }

  static Future<dynamic> decodeJsonFilePath(String filePath) async {
    if (filePath.isEmpty) {
      return [];
    } else {
      final loadedJsonFile = await File(filePath).readAsString();
      return jsonDecode(loadedJsonFile);
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
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowCompression: false,
            type: FileType.custom,
            allowedExtensions: ['xls', 'xlsx', 'xlsm']);
        return File(result?.files.first.path ?? '');
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
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowCompression: false,
            type: FileType.custom,
            allowedExtensions: ['csv', 'tsv', 'txt']);
        return File(result?.files.first.path ?? '');
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
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowCompression: false,
            type: FileType.custom,
            allowedExtensions: ['json']);
        return File(result?.files.first.path ?? '');
      }
    } else {
      print('web not supported yet');
      return File('');
    }
  }
}
