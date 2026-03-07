import 'dart:io';

abstract class IStorageRepository {
  Future<String> uploadProfileImage(String uid, File image);
  Future<String> uploadBannerImage(String uid, File image);
  Future<void> deleteImage(String path);
}
