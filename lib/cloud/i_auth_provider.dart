/// Abstract interface for authentication.
///
/// Swap the implementation in [CloudRegistry] to migrate providers.
abstract interface class IAuthProvider {
  /// Sign in with email + password. Throws on failure.
  Future<void> signInWithPassword(String email, String password);

  /// Register a new account. [metadata] is arbitrary key-value data
  /// (e.g. `{'full_name': 'John Doe'}`). Throws on failure.
  Future<void> signUp(
    String email,
    String password, {
    Map<String, dynamic> metadata = const {},
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password-reset email.
  Future<void> resetPassword(String email);

  /// The authenticated user's unique ID, or null if not signed in.
  String? get currentUserId;

  /// The authenticated user's email, or null if not signed in.
  String? get currentUserEmail;

  /// Arbitrary metadata attached to the user account (e.g. full_name).
  Map<String, dynamic> get currentUserMetadata;

  /// The current short-lived access token for API requests, or null.
  String? get accessToken;

  /// Whether a valid session currently exists.
  bool get isSignedIn;
}
