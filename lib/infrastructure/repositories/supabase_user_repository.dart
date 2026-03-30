import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/repositories/user_repository.dart';

class SupabaseUserRepository implements IUserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> createUser(UserEntity user) async {
    await _supabase.from('profiles').upsert({
      'id': user.uid,
      'full_name': user.name,
      'username': user.username,
      'bio': user.bio,
      'avatar_url': user.photoUrl,
      'public_url': user.publicUrl,
      'created_at': user.createdAt.toIso8601String(),
    });
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final data = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
    if (data == null) return null;

    // Fetch social links
    final linksData = await _supabase.from('social_links').select().eq('user_id', uid);
    final socialLinks = (linksData as List).map((l) => SocialLinkEntity.fromMap(l)).toList();

    return UserEntity(
      uid: data['id'],
      name: data['full_name'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['avatar_url'],
      publicUrl: data['public_url'],
      socialLinks: socialLinks,
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _supabase.from('profiles').update({
      'full_name': user.name,
      'username': user.username,
      'bio': user.bio,
      'avatar_url': user.photoUrl,
      'public_url': user.publicUrl,
    }).eq('id', user.uid);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final data = await _supabase.from('profiles').select('username').eq('username', username).maybeSingle();
    return data == null;
  }

  @override
  Future<void> addSocialLink(String uid, SocialLinkEntity link) async {
    await _supabase.from('social_links').insert({
      'user_id': uid,
      ...link.toMap(),
    });
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    await _supabase.from('social_links').update(link.toMap()).eq('id', link.id);
  }

  @override
  Future<void> updateSocialLinks(String uid, List<SocialLinkEntity> links) async {
    // Delete existing and bulk insert
    await _supabase.from('social_links').delete().eq('user_id', uid);
    if (links.isNotEmpty) {
      await _supabase.from('social_links').insert(
        links.map((l) => {'user_id': uid, ...l.toMap()}).toList(),
      );
    }
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    await _supabase.from('social_links').delete().eq('id', linkId);
  }

  @override
  Future<void> incrementViews(String uid) async {
    // Analytics table insertion
    await _supabase.from('analytics').insert({
      'user_id': uid,
      'event_type': 'view',
    });
  }

  @override
  Future<void> incrementClicks(String uid) async {
    await _supabase.from('analytics').insert({
      'user_id': uid,
      'event_type': 'click',
    });
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) async {
    final data = await _supabase.from('profiles').select().eq('username', username).maybeSingle();
    if (data == null) return null;
    return getUser(data['id']);
  }

  @override
  Future<void> markQrAsGenerated(String uid) async {
    await _supabase.from('profiles').update({
      'qr_generated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }

  @override
  Future<Map<String, dynamic>> getAnalytics(String uid) async {
    final views = await _supabase.from('analytics').select('id').eq('user_id', uid).eq('event_type', 'view');
    final clicks = await _supabase.from('analytics').select('id').eq('user_id', uid).eq('event_type', 'click');
    
    return {
      'total_views': views.length,
      'total_clicks': clicks.length,
    };
  }

  @override
  Future<void> deleteAccount(String uid) async {
    // Delete profile (cascades to social_links & analytics if FKs are set to CASCADE)
    await _supabase.from('profiles').delete().eq('id', uid);
  }
}
