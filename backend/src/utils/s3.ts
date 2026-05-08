import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';

// ── Config ─────────────────────────────────────────────────────────────────────
const REGION = process.env.AWS_REGION ?? 'ap-south-1';
const BUCKET = process.env.S3_BUCKET  ?? 'griva-media';

// Explicit IAM credentials take priority; falls back to instance-role /
// default provider chain when the vars are absent.
const credentialArgs = process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY
  ? {
      credentials: {
        accessKeyId:     process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      },
    }
  : {};

const s3 = new S3Client({ region: REGION, ...credentialArgs });

// ── Limits ─────────────────────────────────────────────────────────────────────
const MAX_BYTES = 50 * 1024 * 1024; // 50 MB

// Presigned GET URLs are valid for 24 hours.
// Flutter caches images locally (Drift) so regeneration is rare.
const PRESIGNED_EXPIRY_SECONDS = 60 * 60 * 24; // 24 h

// ── MIME allowlist ─────────────────────────────────────────────────────────────
const ALLOWED_MIME: Record<string, string> = {
  'image/jpeg':        '.jpg',
  'image/jpg':         '.jpg',
  'image/png':         '.png',
  'image/webp':        '.webp',
  'image/gif':         '.gif',
  'image/bmp':         '.bmp',
  'video/mp4':         '.mp4',
  'video/quicktime':   '.mov',
  'video/x-msvideo':   '.avi',
  'application/pdf':   '.pdf',
  'application/dicom': '.dcm',
  'image/x-dicom':     '.dcm',
};

// ── Valid prefixes (S3 top-level folders) ─────────────────────────────────────
export type S3Prefix = 'cases' | 'reports' | 'uploads' | 'patients';

// ── Error types ────────────────────────────────────────────────────────────────
export class S3ValidationError extends Error {
  constructor(message: string, public readonly statusCode: number = 400) {
    super(message);
    this.name = 'S3ValidationError';
  }
}

export class S3UploadError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'S3UploadError';
  }
}

// ── Validation helpers ─────────────────────────────────────────────────────────
export function validateMime(mimeType: string): string {
  const normalized = mimeType.toLowerCase().split(';')[0]?.trim() ?? '';
  const ext = ALLOWED_MIME[normalized];
  if (!ext) {
    throw new S3ValidationError(
      `File type '${normalized}' is not allowed. ` +
      `Supported: images (jpeg/png/webp), video (mp4/mov/avi), pdf, dicom.`,
      415,
    );
  }
  return ext;
}

export function validateSize(sizeBytes: number): void {
  if (sizeBytes > MAX_BYTES) {
    const mb = (sizeBytes / 1024 / 1024).toFixed(1);
    throw new S3ValidationError(`File size ${mb} MB exceeds the 50 MB limit.`, 413);
  }
}

// ── Key extraction ─────────────────────────────────────────────────────────────
/**
 * Extract an S3 object key from a presigned (or public) S3 URL.
 * Returns null if the URL is not from this bucket.
 */
export function extractS3Key(url: string): string | null {
  try {
    const u    = new URL(url);
    const host = `${BUCKET}.s3.${REGION}.amazonaws.com`;
    if (u.hostname === host) {
      return decodeURIComponent(u.pathname.slice(1)); // strip leading /
    }
  } catch {
    // not a URL — already a key
    if (url && !url.startsWith('http') && url.includes('/')) return url;
  }
  return null;
}

// ── Presigned GET URL ──────────────────────────────────────────────────────────
/**
 * Generate a temporary GET URL for a private S3 object.
 * Presigned URL generation is a local crypto operation — no network call.
 */
export async function getPresignedUrl(
  key:       string,
  expiresIn: number = PRESIGNED_EXPIRY_SECONDS,
): Promise<string> {
  return getSignedUrl(
    s3,
    new GetObjectCommand({ Bucket: BUCKET, Key: key }),
    { expiresIn },
  );
}

// ── File entry helpers ─────────────────────────────────────────────────────────
export interface StoredFile {
  key:  string;
  name: string;
  type: string;
  size: number;
}

export interface ServedFile extends StoredFile {
  url: string; // fresh presigned GET URL added at response time
}

/**
 * Normalise the files array received in POST /cases.
 * Accepts both new format { key, name, type, size } and legacy { url, name, type, size }.
 */
export function normalizeIncomingFiles(
  files: Array<Record<string, unknown>>,
): StoredFile[] {
  return files.map((f, i) => {
    const key =
      (f['key'] as string | undefined) ??
      (f['url'] ? extractS3Key(f['url'] as string) : null);

    if (!key) {
      throw new S3ValidationError(`File at index ${i} is missing a valid S3 key.`);
    }
    return {
      key,
      name: (f['name'] as string) || 'file',
      type: (f['type'] as string) || 'application/octet-stream',
      size: Number(f['size'] ?? 0),
    };
  });
}

/**
 * Enrich a stored files array with fresh presigned URLs before sending to client.
 * Always generates fresh URLs — call at response time, never cache the result.
 */
export async function addPresignedUrls(files: unknown): Promise<ServedFile[]> {
  const raw = Array.isArray(files) ? (files as Array<Record<string, unknown>>) : [];
  return Promise.all(
    raw.map(async (f) => {
      const key = (f['key'] as string | undefined) ?? extractS3Key((f['url'] as string) ?? '');
      if (key) {
        const url = await getPresignedUrl(key);
        return { key, url, name: f['name'] as string, type: f['type'] as string, size: Number(f['size'] ?? 0) };
      }
      // Legacy entry with no extractable key — return as-is so old data doesn't break
      return f as ServedFile;
    }),
  );
}

// ── Upload ─────────────────────────────────────────────────────────────────────
export async function uploadToS3(params: {
  prefix:       S3Prefix;
  buffer:       Buffer;
  originalName: string;
  mimeType:     string;
}): Promise<{ key: string; url: string }> {
  validateSize(params.buffer.length);
  const ext = validateMime(params.mimeType);

  // UUID filename — no user-controlled path segments, prevents traversal
  const key = `${params.prefix}/${uuidv4()}${ext}`;

  try {
    await s3.send(new PutObjectCommand({
      Bucket:             BUCKET,
      Key:                key,
      Body:               params.buffer,
      ContentType:        params.mimeType.toLowerCase().split(';')[0]?.trim(),
      ContentDisposition: `inline; filename="${encodeURIComponent(path.basename(params.originalName))}"`,
    }));
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes('InvalidAccessKeyId') || msg.includes('SignatureDoesNotMatch')) {
      throw new S3UploadError('AWS credentials are invalid. Check AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY in .env.');
    }
    if (msg.includes('NoSuchBucket')) {
      throw new S3UploadError(`S3 bucket '${BUCKET}' not found in region '${REGION}'.`);
    }
    if (msg.includes('AccessDenied')) {
      throw new S3UploadError(`Access denied to bucket '${BUCKET}'. Check IAM policy.`);
    }
    console.error('[S3] Upload error:', msg);
    throw new S3UploadError(`Upload failed: ${msg}`);
  }

  // Return the key (permanent, for DB storage) and a fresh presigned URL (for immediate display)
  const url = await getPresignedUrl(key);
  return { key, url };
}

// ── Delete ─────────────────────────────────────────────────────────────────────
export async function deleteFromS3(key: string): Promise<void> {
  try {
    await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[S3] Delete failed:', key, msg);
    throw new S3UploadError(`Delete failed: ${msg}`);
  }
}

// ── Startup log ────────────────────────────────────────────────────────────────
export function logS3Config(): void {
  const credsSource = process.env.AWS_ACCESS_KEY_ID ? 'explicit (.env)' : 'default provider chain';
  console.log(`[S3] region=${REGION}  bucket=${BUCKET}  credentials=${credsSource}  presigned-expiry=24h`);
  if (!process.env.S3_BUCKET) console.warn('[S3] S3_BUCKET not set — using default: griva-media');
}
