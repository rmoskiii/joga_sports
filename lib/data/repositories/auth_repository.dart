/// Sign-in. The demo signs straight in as Ray.
///
/// Real version: Supabase Auth with Apple, Google and email.
abstract interface class AuthRepository {
  bool get isSignedIn;

  Future<void> signInWithApple();
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email);
  Future<void> signOut();
}
