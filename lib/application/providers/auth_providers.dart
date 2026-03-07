import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/supabase/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository(); 
});

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChanged;
});
