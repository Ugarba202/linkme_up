
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/social_link_entity.dart';

class UserStateNotifier extends StateNotifier<UserEntity?> {
  UserStateNotifier() : super(null);

  void setUser(UserEntity user) {
    state = user;
  }

  void addSocialLink(SocialLinkEntity link) {
    if (state == null) return;
    
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.add(link);
    state = state!.copyWith(socialLinks: currentLinks);
  }

  void removeSocialLink(String id) {
    if (state == null) return;
    
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.removeWhere((l) => l.id == id);
    state = state!.copyWith(socialLinks: currentLinks);
  }
}

final userProvider = StateNotifierProvider<UserStateNotifier, UserEntity?>((ref) {
  return UserStateNotifier();
});
