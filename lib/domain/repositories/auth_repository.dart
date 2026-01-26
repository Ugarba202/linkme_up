abstract class IAuthRepository {
  Future<void> sendOtp(String phoneNumber);
  Future<void> verifyOtp(String code);
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
}
