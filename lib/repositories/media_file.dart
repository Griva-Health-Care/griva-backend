/// Domain model for a file (image / video / PDF) attached to a patient.
///
/// Mirrors the [MediaFiles] table but is fully decoupled from Drift so the
/// same type can be returned by any [IMediaRepository] implementation.
class MediaFile {
  // ── Identity ───────────────────────────────────────────────────────────────
  final int?   id;       // SQLite rowid — local only
  final String uuid;     // Stable cross-device identifier (UUIDv4)

  // ── Ownership ──────────────────────────────────────────────────────────────
  final String patientUuid;
  final String doctorId;

  // ── Classification ─────────────────────────────────────────────────────────
  /// 'image' | 'video' | 'pdf'
  final String fileType;

  // ── Storage ────────────────────────────────────────────────────────────────
  /// Absolute path on this device; null if not yet downloaded.
  final String? localPath;

  /// Firebase Storage download URL; null until uploaded.
  final String? cloudUrl;

  // ── Metadata ───────────────────────────────────────────────────────────────
  final String  fileName;
  final String? mimeType;
  final int?    fileSize;
  final String? checksum;

  // ── Sync ───────────────────────────────────────────────────────────────────
  /// 'local_only' | 'pending_upload' | 'uploading' | 'synced' | 'error'
  final String syncStatus;
  final int    uploadAttempts;

  // ── Soft delete ────────────────────────────────────────────────────────────
  final DateTime? deletedAt;

  // ── Timestamps ─────────────────────────────────────────────────────────────
  final DateTime? capturedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MediaFile({
    this.id,
    required this.uuid,
    required this.patientUuid,
    required this.doctorId,
    required this.fileType,
    this.localPath,
    this.cloudUrl,
    required this.fileName,
    this.mimeType,
    this.fileSize,
    this.checksum,
    this.syncStatus = 'local_only',
    this.uploadAttempts = 0,
    this.deletedAt,
    this.capturedAt,
    this.createdAt,
    this.updatedAt,
  });

  MediaFile copyWith({
    int?     id,
    String?  uuid,
    String?  patientUuid,
    String?  doctorId,
    String?  fileType,
    String?  localPath,
    String?  cloudUrl,
    String?  fileName,
    String?  mimeType,
    int?     fileSize,
    String?  checksum,
    String?  syncStatus,
    int?     uploadAttempts,
    DateTime? deletedAt,
    DateTime? capturedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MediaFile(
    id:             id             ?? this.id,
    uuid:           uuid           ?? this.uuid,
    patientUuid:    patientUuid    ?? this.patientUuid,
    doctorId:       doctorId       ?? this.doctorId,
    fileType:       fileType       ?? this.fileType,
    localPath:      localPath      ?? this.localPath,
    cloudUrl:       cloudUrl       ?? this.cloudUrl,
    fileName:       fileName       ?? this.fileName,
    mimeType:       mimeType       ?? this.mimeType,
    fileSize:       fileSize       ?? this.fileSize,
    checksum:       checksum       ?? this.checksum,
    syncStatus:     syncStatus     ?? this.syncStatus,
    uploadAttempts: uploadAttempts ?? this.uploadAttempts,
    deletedAt:      deletedAt      ?? this.deletedAt,
    capturedAt:     capturedAt     ?? this.capturedAt,
    createdAt:      createdAt      ?? this.createdAt,
    updatedAt:      updatedAt      ?? this.updatedAt,
  );
}
