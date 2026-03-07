import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> sendEmailVerificationLink(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }

  @override
  Future<bool> isEmailVerified() async {
    final session = _supabase.auth.currentSession;
    return session != null && session.user.emailConfirmedAt != null;
  }

  @override
  Future<String?> signInAnonymously() async {
    // Supabase supports anonymous sign-in if enabled in the dashboard
    final response = await _supabase.auth.signInAnonymously();
    return response.user?.id;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged =>
      _supabase.auth.onAuthStateChange.map((data) => data.session?.user.id);
}
