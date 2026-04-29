import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';

class PdfService {
  static Future<bool> _checkDirectoryAccess() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final testFile = File('${directory.path}/test_write_permission.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> _getPdfDirectory() async {
    if (Platform.isWindows || Platform.isLinux) {
      // For desktop platforms, use documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${documentsDir.path}/PDFs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      return pdfDir.path;
    } else {
      // For mobile platforms, use app documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<String?> createImagePdf(List<Uint8List> images, String filename) async {
    try {
      // Check if we can write to the directory
      final hasAccess = await _checkDirectoryAccess();
      if (!hasAccess) {
        throw Exception('Cannot access storage directory. Please check app permissions.');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add pages for each image
      for (final imageBytes in images) {
        final image = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      // Get appropriate directory for the platform
      final pdfDir = await _getPdfDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFilename = filename.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('$pdfDir/${safeFilename}_$timestamp.pdf');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Error creating PDF: $e');
    }
  }

  static Future<void> openPdf(String filePath) async {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        // For desktop platforms, use the default system PDF viewer
        await OpenFile.open(filePath);
      } else {
        // For mobile platforms
        await OpenFile.open(filePath);
      }
    } catch (e) {
      throw Exception('Error opening PDF: $e');
    }
  }

  static Future<String?> createDetailedPdf({
    required List<Uint8List> images,
    required String patientName,
    required String patientId,
    String? dateOfVisit,
    String? notes,
  }) async {
    try {
      // Check if we can write to the directory
      final hasAccess = await _checkDirectoryAccess();
      if (!hasAccess) {
        throw Exception('Cannot access storage directory. Please check app permissions.');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add title page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Medical Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Patient Name: $patientName'),
                pw.Text('Patient ID: $patientId'),
                if (dateOfVisit != null) pw.Text('Date of Visit: $dateOfVisit'),
                if (notes != null) ...[
                  pw.SizedBox(height: 10),
                  pw.Text('Notes: $notes'),
                ],
                pw.SizedBox(height: 20),
                pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}'),
              ],
            );
          },
        ),
      );

      // Add image pages
      for (int i = 0; i < images.length; i++) {
        final imageBytes = images[i];
        final image = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Header(
                    level: 1,
                    child: pw.Text('Image ${i + 1}', style: pw.TextStyle(fontSize: 18)),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(image, fit: pw.BoxFit.contain),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Get appropriate directory for the platform
      final pdfDir = await _getPdfDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safePatientName = patientName.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('$pdfDir/${safePatientName}_report_$timestamp.pdf');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Error creating detailed PDF: $e');
    }
  }

  static String _getPlatformInfo() {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }

  static Future<String> getPdfDirectoryPath() async {
    return await _getPdfDirectory();
  }
} 