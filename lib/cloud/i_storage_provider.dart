import 'dart:io';

/// Abstract interface for cloud file storage.
///
/// Swap the implementation in [CloudRegistry] to migrate providers.
abstract interface class IStorageProvider {
  /// Upload [file] to [bucket] at [path].
  /// Returns the public URL of the uploaded file.
  Future<String> upload(
    String bucket,
    String path,
    File file, {
    String? contentType,
  });

  /// Return the publicly accessible URL for an already-uploaded file.
  String getPublicUrl(String bucket, String path);

  /// Delete the file at [path] in [bucket].
  Future<void> delete(String bucket, String path);
}
