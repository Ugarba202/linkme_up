import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class SupabaseUserRepository implements IUserRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> createUser(UserEntity user) async {
    await _client.from('profiles').upsert(_userToSupabaseMap(user));
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final response = await _client
        .from('profiles')
        .select('*, social_links(*)')
        .eq('id', uid)
        .single();
    
    if (response == null) return null;
    return _userFromSupabaseMap(response);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _client
        .from('profiles')
        .update(_userToSupabaseMap(user))
        .eq('id', user.uid);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final response = await _client
        .from('profiles')
        .select('username')
        .eq('username', username.toLowerCase())
        .maybeSingle();
    return response == null;
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) async {
    final response = await _client
        .from('profiles')
        .select('*, social_links(*)')
        .eq('username', username.toLowerCase())
        .maybeSingle();
    
    if (response == null) return null;
    return _userFromSupabaseMap(response);
  }

  @override
  Future<void> addSocialLink(String uid, SocialLinkEntity link) async {
    final linkMap = _linkToSupabaseMap(link, isInsert: true);
    await _client.from('social_links').insert({
      'user_id': uid,
      ...linkMap,
    });
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    await _client
        .from('social_links')
        .update(_linkToSupabaseMap(link))
        .eq('id', link.id);
  }

  @override
  Future<void> updateSocialLinks(String uid, List<SocialLinkEntity> links) async {
    // In Supabase, we can use a transaction or upsert multiple
    final linkMaps = links.map((l) => {
      'user_id': uid,
      ..._linkToSupabaseMap(l),
    }).toList();
    
    await _client.from('social_links').upsert(linkMaps);
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    await _client.from('social_links').delete().eq('id', linkId);
  }

  @override
  Future<void> incrementViews(String uid) async {
    await _client.rpc('increment_profile_views', params: {'profile_id': uid});
  }

  @override
  Future<void> incrementClicks(String uid) async {
    await _client.rpc('increment_profile_clicks', params: {'profile_id': uid});
  }

  @override
  Future<void> markQrAsGenerated(String uid) async {
    await _client.from('profiles').update({
      'is_qr_generated': true,
      'qr_generated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }

  // Mappers
  Map<String, dynamic> _userToSupabaseMap(UserEntity user) {
    return {
      'id': user.uid,
      'full_name': user.name,
      'username': user.username.isEmpty ? null : user.username.toLowerCase(),
      'country': user.country,
      'avatar_url': user.photoUrl,
      'banner_url': user.bannerUrl,
      'bio': user.bio,
      'public_url': user.publicUrl,
      'profile_completed': user.profileCompleted,
      'views': user.views,
      'clicks': user.clicks,
      'is_qr_generated': user.isQrGenerated,
      'qr_generated_at': user.qrGeneratedAt?.toIso8601String(),
    };
  }

  UserEntity _userFromSupabaseMap(Map<String, dynamic> map) {
    final socialLinksList = (map['social_links'] as List? ?? [])
        .map((l) => _linkFromSupabaseMap(l as Map<String, dynamic>))
        .toList();

    return UserEntity(
      uid: map['id'] ?? '',
      name: map['full_name'] ?? '',
      username: map['username'] ?? '',
      country: map['country'] ?? 'Nigeria',
      photoUrl: map['avatar_url'],
      bannerUrl: map['banner_url'],
      bio: map['bio'] ?? '',
      publicUrl: map['public_url'],
      profileCompleted: map['profile_completed'] ?? false,
      socialLinks: socialLinksList,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      isQrGenerated: map['is_qr_generated'] ?? false,
      qrGeneratedAt: map['qr_generated_at'] != null 
          ? DateTime.parse(map['qr_generated_at']) 
          : null,
    );
  }

  Map<String, dynamic> _linkToSupabaseMap(SocialLinkEntity link, {bool isInsert = false}) {
    final map = {
      'platform': link.platform.name,
      'username': link.username,
      'url': link.url,
      'is_visible': link.isVisible,
      'display_order': link.order,
    };
    
    // Only include ID if not an insert or if ID is already set
    if (!isInsert || link.id.isNotEmpty) {
      map['id'] = link.id;
    }
    
    return map;
  }

  SocialLinkEntity _linkFromSupabaseMap(Map<String, dynamic> map) {
    return SocialLinkEntity(
      id: map['id'] ?? '',
      platform: SocialPlatform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'other'),
        orElse: () => SocialPlatform.other,
      ),
      username: map['username'] ?? '',
      url: map['url'] ?? '',
      isVisible: map['is_visible'] ?? true,
      order: map['display_order'] ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
