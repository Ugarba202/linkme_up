import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements IAuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<String?> signInAnonymously() async {
    final response = await _supabase.auth.signInAnonymously();
    return response.user?.id;
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user.id);
  }

  @override
  Future<bool> isEmailVerified() async {
    return _supabase.auth.currentUser?.emailConfirmedAt != null;
  }

  @override
  Future<void> sendEmailVerificationLink(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }
}
