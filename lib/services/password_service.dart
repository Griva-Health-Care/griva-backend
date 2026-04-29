import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

class PasswordService {
  // Use bcrypt for strong hashing with per-password salt on native platforms.
  // On web, use plain text for simplicity (not recommended for production).
  static String hashPassword(String password) {
    if (kIsWeb) {
      return password; // Plain text on web
    } else {
      // Default cost factor 12 (can be adjusted).
      return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    }
  }

  static bool verifyPassword(String password, String hash) {
    if (kIsWeb) {
      return password == hash; // Plain text comparison on web
    } else {
      try {
        return BCrypt.checkpw(password, hash);
      } catch (_) {
        return false;
      }
    }
  }

  static bool isHashed(String value) {
    if (kIsWeb) {
      return false; // On web, not hashed
    } else {
      // bcrypt hashes start with $2a$, $2b$, or $2y$
      return value.startsWith(r'$2a$') ||
          value.startsWith(r'$2b$') ||
          value.startsWith(r'$2y$');
    }
  }
}
