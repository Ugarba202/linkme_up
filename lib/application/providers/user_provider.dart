import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../infrastructure/firebase/firestore_user_repository.dart';

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return FirestoreUserRepository();
});

class UserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() => null;

  void setUser(UserEntity user) {
    state = user;
  }

  Future<void> updateName(String newName) async {
    if (state == null) return;
    final updated = state!.copyWith(name: newName);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updateEmail(String newEmail) async {
    if (state == null) return;
    // Note: In a real app, email update might require re-auth or special handling in Firebase Auth
    final updated = state!.copyWith(email: newEmail);
    state = updated;
  }

  Future<void> updateUsername(String newUsername) async {
    if (state == null) return;
    final updated = state!.copyWith(username: newUsername);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updateBio(String newBio) async {
    if (state == null) return;
    final updated = state!.copyWith(bio: newBio);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updateCountry(String newCountry) async {
    if (state == null) return;
    final updated = state!.copyWith(country: newCountry);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updatePhotoUrl(String newPhotoUrl) async {
    if (state == null) return;
    final updated = state!.copyWith(photoUrl: newPhotoUrl);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updateBannerUrl(String newBannerUrl) async {
    if (state == null) return;
    final updated = state!.copyWith(bannerUrl: newBannerUrl);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  Future<void> updatePhoneNumber(String? newPhone) async {
    if (state == null) return;
    final updated = state!.copyWith(phoneNumber: newPhone);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }

  void addSocialLink(SocialLinkEntity link) {
    if (state == null) return;
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.add(link);
    state = state!.copyWith(socialLinks: currentLinks);
    // Note: Social links would ideally be persisted to their sub-collection here
  }

  void removeSocialLink(String id) {
    if (state == null) return;
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.removeWhere((l) => l.id == id);
    state = state!.copyWith(socialLinks: currentLinks);
  }

  void toggleSocialVisibility(String id) {
    if (state == null) return;
    final currentLinks = state!.socialLinks.map((link) {
      if (link.id == id) {
        return link.copyWith(isVisible: !link.isVisible);
      }
      return link;
    }).toList();
    state = state!.copyWith(socialLinks: currentLinks);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserEntity?>(() {
  return UserNotifier();
});
