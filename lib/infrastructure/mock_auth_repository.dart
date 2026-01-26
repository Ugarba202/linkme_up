import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<void> sendOtp(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print("MOCK: OTP sent to $phoneNumber");
  }

  @override
  Future<void> verifyOtp(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    if (code == "123456") {
      print("MOCK: OTP Verified");
    } else {
      throw Exception("Invalid OTP");
    }
  }

  @override
  Future<void> signOut() async {
    print("MOCK: Signed out");
  }

  @override
  Stream<String?> get onAuthStateChanged => Stream.value(null);
}
