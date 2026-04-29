import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoService {
  static const String examinationVideosFolder = 'examination_videos';

  static Future<Directory> _getDocumentsDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<Directory> _getExaminationVideosDirectory() async {
    final documentsDir = await _getDocumentsDirectory();
    final videosDir =
        Directory(path.join(documentsDir.path, examinationVideosFolder));

    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }

    return videosDir;
  }

  /// Save a captured examination video for a patient into a folder-only structure:
  /// <documents>/examination_videos/patient_<id>/video_<timestamp>.mp4
  static Future<String> saveExaminationVideo(
    Uint8List videoBytes,
    int patientId, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final videosDir = await _getExaminationVideosDirectory();
      final patientDir =
          Directory(path.join(videosDir.path, 'patient_$patientId'));
      if (!await patientDir.exists()) {
        await patientDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'video_$timestamp.mp4';
      final filePath = path.join(patientDir.path, filename);

      final file = File(filePath);
      await file.writeAsBytes(videoBytes);

      print('Video saved successfully: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving video: $e');
      rethrow;
    }
  }

  /// Return all examination videos for a patient from the filesystem only.
  static Future<List<String>> getPatientVideos(int patientId) async {
    try {
      final videosDir = await _getExaminationVideosDirectory();
      final patientDir =
          Directory(path.join(videosDir.path, 'patient_$patientId'));

      if (!await patientDir.exists()) {
        return [];
      }

      final files = await patientDir.list().toList();
      final videoFiles = files
          .where((f) =>
              f is File &&
              (f.path.toLowerCase().endsWith('.mp4') ||
                  f.path.toLowerCase().endsWith('.mov') ||
                  f.path.toLowerCase().endsWith('.avi')))
          .map((f) => f.path)
          .toList();

      videoFiles.sort();
      return videoFiles;
    } catch (e) {
      print('Error getting patient videos: $e');
      return [];
    }
  }

  static Future<Uint8List?> loadVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error loading video: $e');
      return null;
    }
  }
}

