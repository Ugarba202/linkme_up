import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/storage_repository.dart';

class SupabaseStorageRepository implements IStorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _avatarBucket = 'avatars';
  static const String _bannerBucket = 'banners';

  @override
  Future<String> uploadProfileImage(String uid, File image) async {
    final fileExt = image.path.split('.').last;
    final fileName = '$uid.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'public/$fileName';

    await _supabase.storage.from(_avatarBucket).upload(
          filePath,
          image,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from(_avatarBucket).getPublicUrl(filePath);
  }

  @override
  Future<String> uploadBannerImage(String uid, File image) async {
    final fileExt = image.path.split('.').last;
    final fileName = '$uid.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'public/$fileName';

    await _supabase.storage.from(_bannerBucket).upload(
          filePath,
          image,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from(_bannerBucket).getPublicUrl(filePath);
  }

  @override
  Future<void> deleteImage(String path) async {
    // Basic implementation - needs to parse bucket and path from URL if full URL is passed
    // For now, assuming path is the relative path within the bucket
    // This part might need refinement depending on how we store the paths
  }
}
