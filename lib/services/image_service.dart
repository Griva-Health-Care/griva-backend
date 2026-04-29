import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class ImageService {
  static const String examinationImagesFolder = 'examination_images';

  // Get the documents directory for storing images
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Create examination images directory if it doesn't exist
  static Future<Directory> getExaminationImagesDirectory() async {
    final documentsDir = await getDocumentsDirectory();
    final examinationDir = Directory(path.join(documentsDir.path, examinationImagesFolder));
    
    if (!await examinationDir.exists()) {
      await examinationDir.create(recursive: true);
    }
    
    return examinationDir;
  }

  // Save captured image to device storage
  static Future<String> saveExaminationImage(
    Uint8List imageBytes, 
    int patientId, 
    Map<String, dynamic>? metadata
  ) async {
    try {
      final examinationDir = await getExaminationImagesDirectory();
      
      // Create patient-specific subdirectory
      final patientDir = Directory(path.join(examinationDir.path, 'patient_$patientId'));
      if (!await patientDir.exists()) {
        await patientDir.create(recursive: true);
      }
      
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'examination_$timestamp.jpg';
      final filePath = path.join(patientDir.path, filename);
      
      // Compress and save image
      final image = img.decodeImage(imageBytes);
      if (image != null) {
        // Resize if too large (optional - adjust as needed)
        img.Image resizedImage = image;
        if (image.width > 1920 || image.height > 1080) {
          resizedImage = img.copyResize(image, width: 1920, height: 1080);
        }
        
        // Encode as JPEG with quality 85
        final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
        
        final file = File(filePath);
        await file.writeAsBytes(compressedBytes);
        
        print('Image saved successfully: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to decode image');
      }
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  // Load image from file path
  static Future<Uint8List?> loadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  // Delete image file
  static Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get all images for a specific patient
  static Future<List<String>> getPatientImages(int patientId) async {
    try {
      final examinationDir = await getExaminationImagesDirectory();
      final patientDir = Directory(path.join(examinationDir.path, 'patient_$patientId'));
      
      if (!await patientDir.exists()) {
        return [];
      }
      
      final files = await patientDir.list().toList();
      final imageFiles = files
          .where((file) => file is File && 
                 (file.path.endsWith('.jpg') || 
                  file.path.endsWith('.jpeg') || 
                  file.path.endsWith('.png')))
          .map((file) => file.path)
          .toList();
      
      // Sort by filename (which includes timestamp)
      imageFiles.sort();
      return imageFiles;
    } catch (e) {
      print('Error getting patient images: $e');
      return [];
    }
  }

  // Clean up old images (optional utility method)
  static Future<void> cleanupOldImages(int daysOld) async {
    try {
      final examinationDir = await getExaminationImagesDirectory();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      await for (final entity in examinationDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            print('Deleted old image: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old images: $e');
    }
  }
}
