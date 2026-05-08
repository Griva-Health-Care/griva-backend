import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../cloud/cloud_registry.dart';
import '../i_media_repository.dart';
import '../media_file.dart';

/// Cloud storage implementation of [IMediaRepository].
///
/// Delegates all file operations to [CloudRegistry.instance.storage].
/// To migrate to a different storage backend (Firebase Storage, S3, etc.),
/// swap the [IStorageProvider] in [CloudRegistry] — this file does not need
/// to change.
///
/// Bucket: patient-media
/// Path: doctors/{doctorId}/patients/{patientUuid}/{uuid}/{fileName}
class CloudMediaRepository implements IMediaRepository {
  static const String _bucket = 'patient-media';

  String _path(MediaFile f) =>
      'doctors/${f.doctorId}/patients/${f.patientUuid}/${f.uuid}/${f.fileName}';

  @override
  Future<List<MediaFile>> getForPatient(String patientUuid) async => [];

  @override
  Future<MediaFile?> getByUuid(String uuid) async => null;

  @override
  Future<MediaFile> create(MediaFile file) async {
    String? cloudUrl;
    if (file.localPath != null) cloudUrl = await _uploadFile(file);
    return file.copyWith(
      cloudUrl:   cloudUrl,
      syncStatus: cloudUrl != null ? 'synced' : 'error',
    );
  }

  @override
  Future<MediaFile> update(MediaFile file) async => file;

  @override
  Future<void> delete(String uuid) async {}

  @override
  Future<List<MediaFile>> getPendingUpload(String doctorId) async => [];

  @override
  Future<void> markSynced(String uuid, String cloudUrl) async {}

  @override
  Future<void> incrementUploadAttempts(String uuid) async {}

  Future<String?> _uploadFile(MediaFile file) async {
    try {
      final localFile = File(file.localPath!);
      if (!localFile.existsSync()) {
        debugPrint('[CLOUD_MEDIA] Local file not found: ${file.localPath}');
        return null;
      }
      final url = await CloudRegistry.instance.storage.upload(
        _bucket,
        _path(file),
        localFile,
        contentType: file.mimeType,
      );
      debugPrint('[CLOUD_MEDIA] Uploaded ${file.uuid} → $url');
      return url;
    } catch (e) {
      debugPrint('[CLOUD_MEDIA] Upload failed for ${file.uuid}: $e');
      return null;
    }
  }
}
