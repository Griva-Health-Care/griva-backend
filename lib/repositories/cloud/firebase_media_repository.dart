import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../i_media_repository.dart';
import '../media_file.dart';

/// Firebase Storage + Firestore metadata implementation of [IMediaRepository].
///
/// Storage layout:
///   doctors/{doctorId}/patients/{patientUuid}/{uuid}/{fileName}
///
/// Firestore metadata:
///   doctors/{doctorId}/media/{uuid}
///
/// This class handles the actual upload/download of binary files.
/// In normal use, [SyncedMediaRepository] (Phase 5) calls this class only
/// when the device has internet and the file is pending upload.
class FirebaseMediaRepository implements IMediaRepository {
  FirebaseMediaRepository({
    FirebaseFirestore? db,
    FirebaseStorage?   storage,
  })  : _db      = db      ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage   _storage;

  CollectionReference<Map<String, dynamic>> _col(String doctorId) =>
      _db.collection('doctors').doc(doctorId).collection('media');

  Reference _storageRef(MediaFile f) => _storage
      .ref('doctors/${f.doctorId}/patients/${f.patientUuid}/${f.uuid}/${f.fileName}');

  // ── Queries ──────────────────────────────────────────────────────────────────

  @override
  Future<List<MediaFile>> getForPatient(String patientUuid) async {
    // Cross-doctor query not feasible; callers should specify doctorId.
    // For now the local repo handles patient-scoped queries.
    return [];
  }

  @override
  Future<MediaFile?> getByUuid(String uuid) async => null;

  // ── Writes ───────────────────────────────────────────────────────────────────

  @override
  Future<MediaFile> create(MediaFile file) async {
    String? cloudUrl;

    // Upload the binary if a local path is available.
    if (file.localPath != null) {
      cloudUrl = await _uploadFile(file);
    }

    final saved = file.copyWith(
      cloudUrl:   cloudUrl,
      syncStatus: cloudUrl != null ? 'synced' : 'error',
    );

    // Write metadata to Firestore.
    await _col(file.doctorId).doc(file.uuid).set({
      ...saved.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[FIREBASE_MEDIA] Uploaded ${file.uuid} → $cloudUrl');
    return saved;
  }

  @override
  Future<MediaFile> update(MediaFile file) async {
    await _col(file.doctorId).doc(file.uuid).set({
      ...file.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return file;
  }

  @override
  Future<void> delete(String uuid) async {
    // Soft-delete: update the Firestore record with a deletedAt timestamp.
    // The Storage object is intentionally kept — hard deletes should be
    // done by a scheduled cloud function after a retention window.
    throw UnimplementedError(
      'Call update() with deletedAt set instead of delete() on Firebase.',
    );
  }

  // ── Sync helpers ─────────────────────────────────────────────────────────────

  @override
  Future<List<MediaFile>> getPendingUpload(String doctorId) async => [];

  @override
  Future<void> markSynced(String uuid, String cloudUrl) async {}

  @override
  Future<void> incrementUploadAttempts(String uuid) async {}

  // ── Internal ─────────────────────────────────────────────────────────────────

  Future<String?> _uploadFile(MediaFile file) async {
    try {
      final localFile = File(file.localPath!);
      if (!localFile.existsSync()) {
        debugPrint('[FIREBASE_MEDIA] Local file not found: ${file.localPath}');
        return null;
      }

      final ref      = _storageRef(file);
      final metadata = SettableMetadata(contentType: file.mimeType);
      await ref.putFile(localFile, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('[FIREBASE_MEDIA] Upload failed for ${file.uuid}: $e');
      return null;
    }
  }
}

/// Extension to serialise [MediaFile] to a plain map for Firestore.
extension _MediaFileMap on MediaFile {
  Map<String, dynamic> toMap() => {
    'uuid':           uuid,
    'patientUuid':    patientUuid,
    'doctorId':       doctorId,
    'fileType':       fileType,
    'localPath':      localPath,
    'cloudUrl':       cloudUrl,
    'fileName':       fileName,
    'mimeType':       mimeType,
    'fileSize':       fileSize,
    'checksum':       checksum,
    'syncStatus':     syncStatus,
    'uploadAttempts': uploadAttempts,
    'deletedAt':      deletedAt?.toIso8601String(),
    'capturedAt':     capturedAt?.toIso8601String(),
  };
}
