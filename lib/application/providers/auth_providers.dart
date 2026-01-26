import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/mock_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return MockAuthRepository();
});

final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChanged;
});
