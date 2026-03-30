import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/storage_repository.dart';

class SupabaseStorageRepository implements IStorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<String> uploadProfileImage(String uid, File image) async {
    final fileName = 'profiles/$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from('avatars').upload(fileName, image);
    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  @override
  Future<String> uploadBannerImage(String uid, File image) async {
    final fileName = 'profiles/$uid/banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from('avatars').upload(fileName, image);
    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  @override
  Future<void> deleteImage(String path) async {
    // Extract file name from URL if needed
    final fileName = path.split('/').last;
    await _supabase.storage.from('avatars').remove([fileName]);
  }
}
