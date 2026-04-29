import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ReportPdfViewerScreen extends StatelessWidget {
  final String filePath;
  final String? title;

  const ReportPdfViewerScreen({
    super.key,
    required this.filePath,
    this.title,
  });

  Future<Uint8List> _loadPdfBytes() async {
    final file = File(filePath);
    return file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final name = filePath.split(Platform.pathSeparator).last;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          title ?? name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<Uint8List>(
        future: _loadPdfBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load report',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error?.toString() ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final bytes = snapshot.data!;

          return PdfPreview(
            build: (format) async => bytes,
            canChangePageFormat: false,
            canChangeOrientation: false,
            allowSharing: true,
            allowPrinting: true,
            pdfFileName: name,
            loadingWidget: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

