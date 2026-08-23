import 'package:flutter/widgets.dart';

Future<String?> saveAndDownloadFile({
  required BuildContext context,
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  String? dialogTitle,
  String? shareSubject,
}) async {
  throw UnsupportedError('Cannot save file on this platform.');
}
