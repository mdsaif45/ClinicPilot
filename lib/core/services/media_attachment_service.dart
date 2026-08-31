import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Offline-first media and attachment service for Patient Complaints (Before/After photos)
/// and Diagnostic Investigations (PDF reports, lab scans).
class MediaAttachmentService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Picks one or more images from gallery or camera
  static Future<List<String>> pickImages({
    required String patientId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      if (source == ImageSource.camera && !kIsWeb) {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo == null) return [];
        final savedPath = await saveFileLocally(patientId: patientId, file: photo);
        return [savedPath];
      }

      // Multi-image picker
      final List<XFile> picked = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return [];

      final List<String> savedPaths = [];
      for (final file in picked) {
        final saved = await saveFileLocally(patientId: patientId, file: file);
        savedPaths.add(saved);
      }
      return savedPaths;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return [];
    }
  }

  /// Picks document/PDF files or images for lab reports
  static Future<List<String>> pickDocuments({
    required String patientId,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
      );

      if (result == null || result.files.isEmpty) return [];

      final List<String> savedPaths = [];
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final xFile = XFile(platformFile.path!, name: platformFile.name);
          final saved = await saveFileLocally(patientId: patientId, file: xFile);
          savedPaths.add(saved);
        } else if (platformFile.bytes != null && kIsWeb) {
          savedPaths.add(platformFile.name);
        }
      }
      return savedPaths;
    } catch (e) {
      debugPrint('Error picking documents: $e');
      return [];
    }
  }

  /// Saves an XFile locally in the patient's media directory
  static Future<String> saveFileLocally({
    required String patientId,
    required XFile file,
  }) async {
    if (kIsWeb) {
      return file.path;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final patientMediaDir = Directory(p.join(appDir.path, 'clinic_pilot', 'patient_media', patientId));
      if (!await patientMediaDir.exists()) {
        await patientMediaDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(file.path).isNotEmpty ? p.extension(file.path) : '.jpg';
      final fileName = '${timestamp}_${p.basenameWithoutExtension(file.name)}$ext';
      final targetPath = p.join(patientMediaDir.path, fileName);

      await file.saveTo(targetPath);
      return targetPath;
    } catch (e) {
      debugPrint('Error saving file locally: $e');
      return file.path;
    }
  }

  /// Opens an attachment (PDF report or image) using the system default viewer
  static Future<void> openAttachment(String filePath) async {
    if (kIsWeb) return;
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('Error opening attachment: $e');
    }
  }

  /// Returns the base directory where patient media and reports are stored
  static Future<Directory?> getMediaRootDirectory() async {
    if (kIsWeb) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return Directory(p.join(appDir.path, 'clinic_pilot', 'patient_media'));
    } catch (e) {
      debugPrint('Error accessing media root: $e');
      return null;
    }
  }

  /// Returns a list of all existing media and attachment files
  static Future<List<File>> getAllMediaFiles() async {
    final rootDir = await getMediaRootDirectory();
    if (rootDir == null || !await rootDir.exists()) return [];

    final files = <File>[];
    await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        files.add(entity);
      }
    }
    return files;
  }
}
