import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/config.dart';
import '../services/abdm_auth_service.dart';

/// Opens the HPR OAuth authorization URL in a WebView.
///
/// Flow:
///   1. WebView loads the HPR auth page (on ABDM servers)
///   2. Doctor authenticates with HPR credentials
///   3. HPR redirects to [Config.abdmBaseUrl]/api/auth/hpr/callback
///   4. Backend processes the OAuth code and returns JSON:
///        { "pre_tenant_token": "...", "expires_in": 300 }
///   5. This screen intercepts the navigation to that callback URL,
///      reads the response body, extracts pre_tenant_token
///   6. If user belongs to multiple tenants → shows a selection dialog
///   7. Pops with true on success, false/null on cancel
class HprLoginScreen extends StatefulWidget {
  final String hprAuthUrl;
  final AbdmAuthService abdmAuth;

  const HprLoginScreen({
    super.key,
    required this.hprAuthUrl,
    required this.abdmAuth,
  });

  @override
  State<HprLoginScreen> createState() => _HprLoginScreenState();
}

class _HprLoginScreenState extends State<HprLoginScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  // The path the backend callback handler lives at
  static const String _callbackPath = '/api/auth/hpr/callback';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (e) =>
            setState(() => _error = 'Page error: ${e.description}'),
        onNavigationRequest: (req) {
          // Intercept when the WebView reaches the backend callback URL.
          // The backend returns JSON directly — we capture the URL and
          // let the WebView load it so we can read the page source.
          if (req.url.contains(_callbackPath)) {
            _handleCallbackUrl(req.url);
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.hprAuthUrl));
  }

  Future<void> _handleCallbackUrl(String callbackUrl) async {
    // Small delay to let the backend respond and the page content render
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Read the page body which contains the backend JSON response
      final body = await _controller
          .runJavaScriptReturningResult('document.body.innerText');

      // body comes back as a JS string — strip surrounding quotes
      final raw = body.toString().replaceAll(r'\n', '').trim();
      final cleaned = raw.startsWith('"') && raw.endsWith('"')
          ? raw.substring(1, raw.length - 1)
          : raw;

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final preTenantToken = widget.abdmAuth.extractPreTenantToken(json);

      if (!mounted) return;
      await _selectTenant(preTenantToken);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'HPR callback failed: $e');
    }
  }

  Future<void> _selectTenant(String preTenantToken) async {
    List<AbdmMembership> memberships;

    try {
      memberships = await widget.abdmAuth.getMemberships(preTenantToken);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      return;
    }

    if (!mounted) return;

    if (memberships.isEmpty) {
      setState(() =>
          _error = 'No active tenant memberships found for this HPR account.');
      return;
    }

    // Single tenant — select automatically
    if (memberships.length == 1) {
      await _finalize(memberships.first.tenantId, preTenantToken);
      return;
    }

    // Multiple tenants — ask the doctor to choose
    final chosen = await showDialog<AbdmMembership>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TenantPickerDialog(memberships: memberships),
    );

    if (chosen == null || !mounted) return;
    await _finalize(chosen.tenantId, preTenantToken);
  }

  Future<void> _finalize(String tenantId, String preTenantToken) async {
    try {
      await widget.abdmAuth.selectTenant(tenantId, preTenantToken);
      if (!mounted) return;
      Navigator.of(context).pop(true); // success
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with ABDM / HPR'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_loading && _error == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _TenantPickerDialog extends StatelessWidget {
  final List<AbdmMembership> memberships;

  const _TenantPickerDialog({required this.memberships});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Organisation'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: memberships.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final m = memberships[i];
            return ListTile(
              title: Text(m.tenantName),
              subtitle: Text(m.role),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(m),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
