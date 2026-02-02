abstract class IAuthRepository {
  Future<void> sendEmailVerificationLink(String email);
  Future<bool> isEmailVerified();
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
}
