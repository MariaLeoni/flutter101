import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

Future<File?> copyAssetToLocal(String fileName) async {
  try {
    var content = await rootBundle.load("assets/$fileName");
    final directory = await getApplicationDocumentsDirectory();
    var file = File("${directory.path}/$fileName");
    file.writeAsBytesSync(content.buffer.asUint8List());

    return file;
  } catch (e) {
    print('Error loading file ${e.toString()}');
    return null;
  }}