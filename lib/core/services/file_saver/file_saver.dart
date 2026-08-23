import 'package:flutter/widgets.dart';

import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart' as impl;

class FileSaverService {
  const FileSaverService._();

  static Future<String?> save({
    required BuildContext context,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    String? dialogTitle,
    String? shareSubject,
  }) {
    return impl.saveAndDownloadFile(
      context: context,
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      dialogTitle: dialogTitle,
      shareSubject: shareSubject,
    );
  }
}
