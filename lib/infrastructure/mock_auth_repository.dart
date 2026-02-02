import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<void> sendEmailVerificationLink(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print("MOCK: Verification link sent to $email");
  }

  @override
  Future<bool> isEmailVerified() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For mock testing, we'll return true to allow the flow to continue
    return true;
  }

  @override
  Future<void> signOut() async {
    print("MOCK: Signed out");
  }

  @override
  Stream<String?> get onAuthStateChanged => Stream.value(null);
}
