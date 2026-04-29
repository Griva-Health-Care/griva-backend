import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'services/abdm_auth_service.dart';
import 'screens/hpr_login_screen.dart';
import 'widgets/centralized_footer.dart';

class GrivaLoginPage extends StatefulWidget {
  final AuthService authService;

  const GrivaLoginPage({super.key, required this.authService});

  @override
  State<GrivaLoginPage> createState() => _GrivaLoginPageState();
}

class _GrivaLoginPageState extends State<GrivaLoginPage> {
  late final AuthService _authService;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignupMode = false;

  final _forgotEmailController = TextEditingController();

  // Signup controllers
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isSignupLoading = false;
  bool _isAbdmLoading = false;

  final AbdmAuthService _abdmAuth = AbdmAuthService();

  @override
  void initState() {
    super.initState();

    _authService = widget.authService;
  }

  void _toggleMode() {
    setState(() => _isSignupMode = !_isSignupMode);
  }

  // ================= LOGIN =================
  void _login() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    debugPrint('[LOGIN] Attempting login for: $email');

    try {
      final success = await _authService.login(email, _passwordController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (success) {
        debugPrint('[LOGIN] Login successful, navigating to HomePage');
        FcmService.instance.init();
        _showSuccessDialog('Welcome back!');
      } else {
        _showErrorDialog('Login failed. Please check your credentials.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('[LOGIN] Login error: $e');
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ================= SIGNUP =================
  void _signup() async {
    if (!_validateSignupForm()) return;

    setState(() => _isSignupLoading = true);

    try {
      final email = _signupEmailController.text.trim();
      final name = _signupNameController.text.trim();

      debugPrint('[LOGIN] Signup started: $email');
      debugPrint('[UI] Name: $name');
      debugPrint('[UI] Email: $email');

      final success = await _authService.register(
        email: email,
        name: name,
        password: _signupPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        debugPrint(
          '[LOGIN] Signup successful, attempting auto-login verification',
        );

        // ✅ CRITICAL: Verify session before navigating
        final verified = await _authService.tryAutoLogin();

        if (!mounted) return;

        if (verified == null) {
          debugPrint('[LOGIN] ❌ Auto-login verification failed');
          _showErrorDialog(
            'Session verification failed. Please log in manually.',
          );
          setState(() => _isSignupLoading = false);
          return;
        }

        debugPrint('[LOGIN] ✅ Session verified, navigating to home');
        _clearSignupForm();
        if (mounted) AppRouter.navigateToHome(context, userEmail: email);
      } else {
        debugPrint('[LOGIN] ❌ Signup registration failed');
        if (mounted) {
          _showErrorDialog(
            'Signup failed. Please check your email and try again.',
          );
        }
      }
    } catch (e) {
      debugPrint('[LOGIN] Signup exception: $e');

      if (!mounted) return;

      // Handle specific error cases
      String errorMessage = 'Signup failed. Please try again.';

      if (e.toString().contains('409') ||
          e.toString().contains('already exists')) {
        errorMessage =
            'This email is already registered. Please log in instead.';
      } else if (e.toString().contains('verification failed')) {
        errorMessage =
            'Session verification failed. Please try logging in manually.';
      }

      _showErrorDialog(errorMessage);
    }

    if (mounted) {
      setState(() => _isSignupLoading = false);
    }
  }

  void _clearSignupForm() {
    _signupNameController.clear();
    _signupEmailController.clear();
    _signupPasswordController.clear();
    _signupConfirmPasswordController.clear();
  }

  bool _validateSignupForm() {
    debugPrint('[LOGIN] Validating signup form');

    if (_signupNameController.text.trim().isEmpty) {
      debugPrint('[LOGIN] Validation: empty name');
      _showErrorDialog('Enter full name');
      return false;
    }

    if (_signupEmailController.text.trim().isEmpty) {
      debugPrint('[LOGIN] Validation: empty email');
      _showErrorDialog('Enter email');
      return false;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_signupEmailController.text)) {
      debugPrint('[LOGIN] Validation: invalid email format');
      _showErrorDialog('Invalid email');
      return false;
    }

    if (_signupPasswordController.text.length < 8) {
      debugPrint('[LOGIN] Validation: password too short');
      _showErrorDialog('Password must be 8+ characters');
      return false;
    }

    if (_signupPasswordController.text !=
        _signupConfirmPasswordController.text) {
      debugPrint('[LOGIN] Validation: passwords do not match');
      _showErrorDialog('Passwords do not match');
      return false;
    }

    debugPrint('[LOGIN] Validation: all fields valid');
    return true;
  }

  // ================= DIALOGS =================
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();

                  if (!_isSignupMode) {
                    AppRouter.navigateToHome(
                      context,
                      userEmail: _emailController.text.trim(),
                    );
                  } else {
                    setState(() => _isSignupMode = false);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 32),

                Text(
                  _isSignupMode ? 'Create Account' : 'Welcome Doctor!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                _isSignupMode ? _buildSignupForm() : _buildLoginForm(),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isSignupMode
                        ? 'Already have an account? Sign In'
                        : 'New user? Sign Up',
                  ),
                ),

                const SizedBox(height: 32),
                const CentralizedFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _inputField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.email,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock,
          obscure: _obscurePassword,
          showPasswordToggle: true,
          onTogglePasswordVisibility:
              () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child:
              _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showForgotPasswordDialog,
          child: const Text('Forgot Password?'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: TextStyle(color: Colors.grey.shade500)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isAbdmLoading ? null : _loginWithAbdm,
          icon: _isAbdmLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.health_and_safety_outlined),
          label: const Text('Login with ABDM / HPR'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  // ================= ABDM / HPR LOGIN =================
  void _loginWithAbdm() async {
    setState(() => _isAbdmLoading = true);
    try {
      final hprUrl = await _abdmAuth.getHprAuthUrl();
      if (!mounted) return;

      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => HprLoginScreen(
            hprAuthUrl: hprUrl,
            abdmAuth: _abdmAuth,
          ),
        ),
      );

      if (!mounted) return;
      if (success == true) {
        _showSuccessDialog('ABDM account connected successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isAbdmLoading = false);
    }
  }

  // ================= FORGOT PASSWORD =================
  void _showForgotPasswordDialog() {
    _forgotEmailController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we will send you a link to reset your password.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _forgotEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = _forgotEmailController.text.trim();
                          if (email.isEmpty) return;

                          setDialogState(() => isLoading = true);

                          try {
                            await _authService.sendPasswordResetEmail(email);
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).pop();
                            _forgotEmailController.clear();
                            if (mounted) _showResetEmailSentDialog(email);
                          } catch (e) {
                            if (!ctx.mounted) return;
                            Navigator.of(ctx).pop();
                            final err = e.toString();
                            final String msg;
                            if (err.contains('network-request-failed') ||
                                err.contains('network') ||
                                err.contains('Network') ||
                                err.contains('SocketException') ||
                                err.contains('connection')) {
                              msg = 'No internet connection. Please check your connectivity and try again.';
                            } else if (err.contains('development mode')) {
                              msg = 'Password reset is not available in development mode.';
                            } else {
                              msg = 'Failed to send reset email. Please check the address and try again.';
                            }
                            if (mounted) _showErrorDialog(msg);
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showResetEmailSentDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Email Sent'),
        content: Text(
          'A password reset link has been sent to $email. Check your inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool showPasswordToggle = false,
    VoidCallback? onTogglePasswordVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon),
        suffixIcon: showPasswordToggle
            ? IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        _inputField(
          controller: _signupNameController,
          hint: 'Full Name',
          icon: Icons.person,
        ),
        const SizedBox(height: 12),
        _inputField(
          controller: _signupEmailController,
          hint: 'Email',
          icon: Icons.email,
        ),
        const SizedBox(height: 12),
        _inputField(
          controller: _signupPasswordController,
          hint: 'Password',
          icon: Icons.lock,
          obscure: true,
        ),
        const SizedBox(height: 12),
        _inputField(
          controller: _signupConfirmPasswordController,
          hint: 'Confirm Password',
          icon: Icons.lock,
          obscure: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSignupLoading ? null : _signup,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child:
              _isSignupLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Account'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }
}
