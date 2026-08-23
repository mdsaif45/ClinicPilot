import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String?> saveAndDownloadFile({
  required BuildContext context,
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  String? dialogTitle,
  String? shareSubject,
}) async {
  final uint8Bytes = Uint8List.fromList(bytes);

  if (Platform.isAndroid || Platform.isIOS) {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(uint8Bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: shareSubject ?? fileName,
    );
    return file.path;
  } else {
    final extension = fileName.contains('.') ? fileName.split('.').last : '';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle ?? 'Save file',
      fileName: fileName,
      bytes: uint8Bytes,
      type: extension.isNotEmpty ? FileType.custom : FileType.any,
      allowedExtensions: extension.isNotEmpty ? [extension] : null,
    );
    if (path != null) {
      final file = File(path);
      await file.writeAsBytes(uint8Bytes, flush: true);
    }
    return path;
  }
}
