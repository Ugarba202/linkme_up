abstract class IAuthRepository {
  Future<void> sendEmailVerificationLink(String email);
  Future<bool> isEmailVerified();
  Future<String?> signInAnonymously();
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
  String? get currentUserId;
}
