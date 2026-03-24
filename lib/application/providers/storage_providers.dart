import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../infrastructure/mock_storage_repository.dart';

final storageRepositoryProvider = Provider<IStorageRepository>((ref) {
  return MockStorageRepository();
});
