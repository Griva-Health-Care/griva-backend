import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../cloud_registry.dart';
import '../i_storage_provider.dart';

/// AWS S3 (via backend) implementation of [IStorageProvider].
///
/// Files are uploaded through POST /cases/upload on the backend,
/// which proxies to S3 via the EC2 instance role.
class BackendStorageProvider implements IStorageProvider {
  BackendStorageProvider({required String baseUrl}) : _base = baseUrl;

  final String _base;

  String? get _token => CloudRegistry.instance.auth.accessToken;

  @override
  Future<String> upload(
    String bucket,
    String path,
    File file, {
    String? contentType,
  }) async {
    final bytes    = await file.readAsBytes();
    final filename = path.split('/').last;
    final mime     = contentType ?? 'application/octet-stream';
    return _uploadBytes(bytes, filename, mime);
  }

  Future<String> uploadBytes(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) => _uploadBytes(bytes, filename, mimeType);

  Future<String> _uploadBytes(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    final tok = _token;
    if (tok == null) throw Exception('Not signed in');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/cases/upload'),
    )
      ..headers['Authorization'] = 'Bearer $tok'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final body     = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 400) {
      throw Exception('Upload failed (${streamed.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['url'] as String;
  }

  @override
  String getPublicUrl(String bucket, String path) {
    // S3 public URLs are returned at upload time and stored as-is.
    // If a full URL is passed, return it directly.
    if (path.startsWith('http')) return path;
    return path;
  }

  @override
  Future<void> delete(String bucket, String path) {
    throw UnimplementedError('Direct S3 delete is not yet exposed by backend');
  }
}
