import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'patient_service.dart';

class MedicalReportService {
  static const String _metadataSuffix = '.meta.json';

  static Future<String?> generateComprehensiveReport({
    required Patient patient,
    required List<Uint8List> images,
    String? chiefComplaint,
    String? cytologyReport,
    String? pathologicalReport,
    String? colposcopyFindings,
    String? finalImpression,
    String? remarks,
    String? treatmentProvided,
    String? precautions,
    String? examiningPhysician,
    String? signatureDate,
    Map<String, String>? forensicExamination,
  }) async {
    try {
      final pdf = pw.Document();

      // --- NEW ROBUST FONT LOADING ---
      pw.ThemeData theme;
      try {
        final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
        final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

        // Explicitly check if font files have content before trying to parse them.
        // A valid TTF file is usually several kilobytes. A small number indicates an empty or invalid file.
        if (fontData.lengthInBytes < 100 || boldFontData.lengthInBytes < 100) {
            print('WARNING: Font files in assets/fonts/ are empty or invalid. Falling back to default fonts.');
            throw Exception('Invalid font file'); // Force fallback to catch block
        }

        final ttf = pw.Font.ttf(fontData);
        final boldTtf = pw.Font.ttf(boldFontData);

        theme = pw.ThemeData.withFont(
          base: ttf,
          bold: boldTtf,
        );
        print('Custom Roboto fonts loaded successfully.');

      } catch (e) {
        print('Could not load custom fonts, using default PDF fonts. Error: $e');
        // Fallback to a default theme if custom fonts fail to load
        theme = pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
          boldItalic: pw.Font.helveticaBoldOblique(),
        );
      }
      // --- END OF FONT LOADING ---

      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          header: (context) => _buildHeader(),
          footer: (context) => _buildFooter(patient, examiningPhysician),
          build: (pw.Context context) {
            return [
              // Patient Information
              _buildPatientInfoSection(patient),
              pw.SizedBox(height: 20),

              // Clinical Findings
              pw.Text('CLINICAL FINDINGS & EXAMINATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _buildClinicalFindings(
                chiefComplaint: chiefComplaint,
                cytologyReport: cytologyReport,
                pathologicalReport: pathologicalReport,
                colposcopyFindings: colposcopyFindings,
                finalImpression: finalImpression,
                remarks: remarks,
              ),
              pw.SizedBox(height: 20),

              // Forensic Examination
              if (forensicExamination != null && forensicExamination.isNotEmpty) ...[
                pw.Text('FORENSIC EXAMINATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildForensicExamination(forensicExamination),
                pw.SizedBox(height: 20),
              ],
              
              // Treatment & Follow-up
              if (treatmentProvided != null && treatmentProvided.isNotEmpty)
                _buildColoredCard('Treatment Provided', treatmentProvided, PdfColors.blue100),
              if (precautions != null && precautions.isNotEmpty)
                _buildColoredCard('Precautions & Follow-up', precautions, PdfColors.amber100),
              
              pw.SizedBox(height: 20),

              // Colposcopy Images
              if (images.isNotEmpty) ...[
                pw.Text('COLPOSCOPY IMAGES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                _buildImageGrid(images),
              ],
            ];
          },
        ),
      );

      // Get appropriate directory for the platform
      final pdfDir = await _getPdfDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safePatientName = patient.patientName.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File('$pdfDir/${safePatientName}_comprehensive_report_$timestamp.pdf');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Write metadata sidecar for visit history cards.
      try {
        final metaFile = File('${file.path}$_metadataSuffix');
        final meta = <String, dynamic>{
          'version': 1,
          'generatedAtMs': timestamp,
          'patientId': patient.id,
          'patientName': patient.patientName,
          'patientExternalId': patient.patientId,
          'reportPath': file.path,
          'imageCount': images.length,
          'chiefComplaint': chiefComplaint,
          'cytologyReport': cytologyReport,
          'pathologicalReport': pathologicalReport,
          'colposcopyFindings': colposcopyFindings,
          'finalImpression': finalImpression,
          'remarks': remarks,
          'treatmentProvided': treatmentProvided,
          'precautions': precautions,
          'examiningPhysician': examiningPhysician,
          'forensicExamination': forensicExamination,
        };
        await metaFile.writeAsString(jsonEncode(meta));
      } catch (e) {
        // Metadata is best-effort; report generation should still succeed.
        print('Warning: failed to write report metadata: $e');
      }

      return file.path;
    } catch (e) {
      throw Exception('Error creating comprehensive report: $e');
    }
  }

  /// List all comprehensive colposcopy reports generated for a given patient.
  ///
  /// This looks into the GrivaReports/Colposcopy folder and matches files whose
  /// names start with the sanitized patient name that we use when saving.
  static Future<List<File>> listReportsForPatient(Patient patient) async {
    final pdfDirPath = await _getPdfDirectory();
    final dir = Directory(pdfDirPath);
    if (!await dir.exists()) {
      return [];
    }

    final safePatientName =
        patient.patientName.replaceAll(RegExp(r'[^\w\s-]'), '_');

    final entities = await dir
        .list()
        .where((e) => e is File && e.path.toLowerCase().endsWith('.pdf'))
        .toList();

    return entities
        .whereType<File>()
        .where((file) {
          final name = p.basename(file.path);
          return name.startsWith('${safePatientName}_comprehensive_report_');
        })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }
  
  static pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Text('COLPOSCOPY REPORT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
        pw.Text('Medical Examination Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildFooter(Patient patient, String? examiningPhysician) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Examining Physician: ${examiningPhysician ?? ''}'),
                pw.SizedBox(height: 20),
                pw.Text('Signature & Date: _________________________'),
              ]
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Report Generated: ${_formatDate(DateTime.now())}'),
                pw.SizedBox(height: 5),
                pw.Text('(This Report is not valid for Medico Legal Cases)', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 9, color: PdfColors.grey)),
              ]
            )
          ]
        ),
      ]
    );
  }

  static pw.Widget _buildPatientInfoSection(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PATIENT INFORMATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Name:', patient.patientName),
                  if (patient.dateOfBirth != null)
                    _buildInfoRow('Age:', '${DateTime.now().year - patient.dateOfBirth!.year} years'),
                  _buildInfoRow('ID No.:', patient.patientId ?? 'N/A'),
                  if (patient.dateOfVisit != null)
                    _buildInfoRow('Date:', _formatDate(patient.dateOfVisit!)),
                  _buildInfoRow('Contraceptive Method:', patient.contraception ?? 'N/A'),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (patient.lastMenstrualDate != null)
                    _buildInfoRow('LMP:', _formatDate(patient.lastMenstrualDate!)),
                  _buildInfoRow('Pregnancy:', patient.pregnant ?? 'N/A'),
                  _buildInfoRow('Abortion History:', patient.abortions?.toString() ?? 'None'),
                  _buildInfoRow('Referred By:', patient.referredBy ?? 'N/A'),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildClinicalFindings({
    String? chiefComplaint,
    String? cytologyReport,
    String? pathologicalReport,
    String? colposcopyFindings,
    String? finalImpression,
    String? remarks,
  }) {
    return pw.Column(
      children: [
        if (chiefComplaint != null && chiefComplaint.isNotEmpty)
          _buildTitledCard('Chief Complaint', chiefComplaint, PdfColors.green),
        
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (cytologyReport != null && cytologyReport.isNotEmpty)
              pw.Expanded(child: _buildTitledCard('Cytology Report', cytologyReport, PdfColors.blue)),
            pw.SizedBox(width: 10),
            if (pathologicalReport != null && pathologicalReport.isNotEmpty)
              pw.Expanded(child: _buildTitledCard('Pathological Report', pathologicalReport, PdfColors.purple)),
          ],
        ),
        
        if (colposcopyFindings != null && colposcopyFindings.isNotEmpty)
          _buildTitledCard('Colposcopy Findings', colposcopyFindings, PdfColors.orange),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (finalImpression != null && finalImpression.isNotEmpty)
              pw.Expanded(child: _buildTitledCard('Final Impression', finalImpression, PdfColors.red)),
            pw.SizedBox(width: 10),
            if (remarks != null && remarks.isNotEmpty)
              pw.Expanded(child: _buildTitledCard('Remarks', remarks, PdfColors.grey)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildForensicExamination(Map<String, String> details) {
    List<pw.Widget> leftColumn = [];
    List<pw.Widget> rightColumn = [];
    
    final allKeys = [
      'Foreign Bodies', 'Skin/Mucosal Trauma', 'Swab Sample', 'Staining Effect',
      'Green Filter', 'Anal Injuries', 'Posterior Fourchette', 'Erythema'
    ];

    int i = 0;
    for (var key in allKeys) {
      if (details.containsKey(key)) {
        final widget = _buildInfoRow('$key:', details[key]!, bold: false);
        if (i < 4) {
          leftColumn.add(widget);
        } else {
          rightColumn.add(widget);
        }
        i++;
      }
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: leftColumn)),
        pw.SizedBox(width: 20),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rightColumn)),
      ],
    );
  }

  static pw.Widget _buildImageGrid(List<Uint8List> images) {
    return pw.GridView(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      children: images.asMap().entries.map((entry) {
        final index = entry.key;
        final imageBytes = entry.value;
        final image = pw.MemoryImage(imageBytes);
        return pw.Column(
          children: [
            pw.Expanded(child: pw.Image(image, fit: pw.BoxFit.contain)),
            pw.SizedBox(height: 5),
            pw.Text('Image ${index + 1}', style: const pw.TextStyle(fontSize: 10)),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildTitledCard(String title, String content, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
        color: PdfColors.grey100,
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color)),
          pw.SizedBox(height: 5),
          pw.Text(content),
        ],
      ),
    );
  }

  static pw.Widget _buildColoredCard(String title, String content, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(content),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, {bool bold = true}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static Future<String> _getPdfDirectory() async {
    // For desktop platforms, use documents directory and a specific subfolder
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final documentsDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${documentsDir.path}/GrivaReports/Colposcopy');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      return pdfDir.path;
    } 
    // For mobile platforms, use app documents directory
    else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<void> openReport(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      throw Exception('Error opening report: $e');
    }
  }

  static Future<Map<String, dynamic>?> readReportMetadata(String pdfPath) async {
    try {
      final metaFile = File('$pdfPath$_metadataSuffix');
      if (!await metaFile.exists()) return null;
      final raw = await metaFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      print('Warning: failed to read report metadata: $e');
      return null;
    }
  }
}