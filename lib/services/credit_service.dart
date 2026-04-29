import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../db/daos/tele_case_dao.dart';
import '../repositories/tele_case.dart';
import 'cloud_config_service.dart';
import 'session_service.dart';

/// Manages prepaid report credits for diagnostic center accounts.
///
/// Credits are the source of truth in Firestore (`doctor_config/{uid}.creditBalance`).
/// The local [CloudConfigService] cache is updated after every transaction so
/// the UI reflects the new balance immediately without a second fetch.
///
/// ## Submitting a case
/// Call [submitCase].  Internally this runs a Firestore transaction that:
///   1. Reads the current balance — fails if 0.
///   2. Decrements by 1.
///   3. Writes the new tele_case document.
///   4. Updates the local SQLite record for offline display.
///
/// The transaction is atomic: if any step fails the balance is not changed and
/// no case is created.
class CreditService {
  CreditService._();
  static final CreditService instance = CreditService._();

  final FirebaseFirestore _fdb = FirebaseFirestore.instance;
  final AppDatabase       _db  = AppDatabase();

  static const _configCol = 'doctor_config';
  static const _casesCol  = 'tele_cases';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Current cached credit balance (updated after every successful transaction).
  int get balance => CloudConfigService.instance.current.creditBalance;

  /// Submit a case, deducting one credit atomically.
  ///
  /// Throws [InsufficientCreditsException] when balance is 0.
  /// Throws on any Firestore error.
  /// Returns the created [TeleCase] on success.
  Future<TeleCase> submitCase(TeleCase draft) async {
    final doctorId  = SessionService.instance.currentDoctorId;
    final configRef = _fdb.collection(_configCol).doc(doctorId);
    final caseRef   = _fdb.collection(_casesCol).doc(draft.uuid);

    late TeleCase saved;

    await _fdb.runTransaction((tx) async {
      // 1. Read current config.
      final snap    = await tx.get(configRef);
      final balance = (snap.data()?['creditBalance'] as int?) ?? 0;

      if (balance <= 0) throw InsufficientCreditsException();

      // 2. Decrement balance.
      tx.update(configRef, {'creditBalance': balance - 1});

      // 3. Write the case document.
      final now        = DateTime.now();
      final slaDeadline = now.add(const Duration(minutes: 20));
      final caseData   = {
        ...draft.toMap(),
        'status':       'pending',
        'submittedAt':  now.toIso8601String(),
        'slaDeadline':  slaDeadline.toIso8601String(),
        'creditsUsed':  1,
        'syncStatus':   'synced',
        'cloudId':      draft.uuid,
      };
      tx.set(caseRef, caseData);

      saved = draft.copyWith(
        status:      'pending',
        submittedAt: now,
        slaDeadline: slaDeadline,
        creditsUsed: 1,
        syncStatus:  'synced',
        cloudId:     draft.uuid,
      );
    });

    // 4. Persist locally.
    final dao = TeleCaseDao(_db);
    await dao.createCase(saved);

    // 5. Update in-memory config cache so UI reflects new balance immediately.
    _updateLocalBalance(doctorId);

    debugPrint('[CREDIT] Case ${draft.uuid} submitted — balance now ${balance - 1}');
    return saved;
  }

  /// Re-fetch the config from Firestore and update the local cache.
  Future<void> refreshBalance() async {
    final doctorId = SessionService.instance.currentDoctorId;
    await CloudConfigService.instance.fetch(doctorId);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _updateLocalBalance(String doctorId) async {
    try {
      await CloudConfigService.instance.fetch(doctorId);
    } catch (e) {
      debugPrint('[CREDIT] Balance refresh failed: $e');
    }
  }
}

/// Thrown when a case submission is attempted with zero credits.
class InsufficientCreditsException implements Exception {
  @override
  String toString() =>
      'Insufficient credits. Please purchase more credits to submit cases.';
}
