import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../db/app_database.dart';
import '../db/daos/tele_case_dao.dart';
import '../repositories/tele_case.dart';
import 'cloud_config_service.dart';
import 'session_service.dart';

/// Manages prepaid report credits for diagnostic center accounts.
///
/// Credits live in Supabase Postgres (`node_app.doctor_config.creditBalance`).
/// The backend handles the atomic deduction transaction — the Flutter app just
/// calls `POST /credits/submit-case` and handles the response.
class CreditService {
  CreditService._();
  static final CreditService instance = CreditService._();

  final AppDatabase _db = AppDatabase();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Current cached credit balance (updated after every successful transaction).
  int get balance => CloudConfigService.instance.current.creditBalance;

  /// Submit a case, deducting one credit atomically on the backend.
  ///
  /// Throws [InsufficientCreditsException] when balance is 0.
  /// Throws on any network/server error.
  /// Returns the created [TeleCase] on success.
  Future<TeleCase> submitCase(TeleCase draft) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('Not signed in');

    if (balance <= 0) throw InsufficientCreditsException();

    final response = await Dio().post(
      '${Config.piBaseUrl}/credits/submit-case',
      data: {
        'uuid':  draft.uuid,
        'notes': draft.notes,
        'files': [],
      },
      options: Options(
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );

    if (response.statusCode == 402) throw InsufficientCreditsException();

    final now         = DateTime.now();
    final slaDeadline = now.add(const Duration(minutes: 20));
    final caseData    = response.data as Map<String, dynamic>;
    final serverCase  = caseData['teleCase'] as Map<String, dynamic>? ?? {};

    final saved = draft.copyWith(
      status:      'pending',
      submittedAt: now,
      slaDeadline: slaDeadline,
      creditsUsed: 1,
      syncStatus:  'synced',
      cloudId:     serverCase['id'] as String? ?? draft.uuid,
    );

    // Persist locally.
    final dao = TeleCaseDao(_db);
    await dao.createCase(saved);

    // Refresh balance cache.
    _updateLocalBalance(SessionService.instance.currentDoctorId);

    debugPrint('[CREDIT] Case ${draft.uuid} submitted — balance now ${balance - 1}');
    return saved;
  }

  /// Re-fetch the config from Supabase and update the local cache.
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
