import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> sendEmailVerificationLink(String email) async {
    // Note: In a real production environment, the URL must be white-listed in Firebase Console
    final acs = ActionCodeSettings(
      // The URL to redirect back to. The domain must be whitelisted in Firebase Console.
      url: 'https://linkmeup-4c623.firebaseapp.com',
      handleCodeInApp: true,
      androidPackageName: 'com.example.linkmeup_app',
      androidInstallApp: true,
      androidMinimumVersion: '1',
      iOSBundleId: 'com.example.linkmeupApp',
    );

    await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: acs,
    );
  }

  @override
  Future<bool> isEmailVerified() async {
    // For passwordless login, the presence of a user indicates they clicked the link
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<String?> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user?.uid;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);
}
