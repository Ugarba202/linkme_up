import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthService implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> sendEmailVerificationLink(String email) async {
    try {
   
      
      var acs = ActionCodeSettings(
        url: 'https://linkmeup-6855b.firebaseapp.com', // Replace with your actual project URL
        handleCodeInApp: true,
        androidPackageName: 'com.example.linkmeup_app', // Replace with your package name
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );
      
      // Save the email locally to complete sign-in later
      // In a real app, you'd use SharedPreferences.
    } catch (e) {
      // If it fails, it might be because the user already exists or other reasons
      rethrow;
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged => 
      _auth.authStateChanges().map((user) => user?.uid);
}
