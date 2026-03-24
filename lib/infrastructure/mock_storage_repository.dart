import 'dart:io';
import '../domain/repositories/storage_repository.dart';

class MockStorageRepository implements IStorageRepository {
  @override
  Future<String> uploadProfileImage(String userId, File image) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://ui-avatars.com/api/?name=Mock+User&background=random';
  }

  @override
  Future<String> uploadBannerImage(String userId, File image) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/200';
  }
  
  @override
  Future<void> deleteImage(String path) async {
    // Mock deletion
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
