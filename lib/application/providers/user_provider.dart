import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';



import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../infrastructure/firebase/firestore_user_repository.dart';

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return FirestoreUserRepository();
});

class UserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    // Initial load from local storage (SharedPreferences)
    _restoreLocalSession();
    return null;
  }

  Future<void> _restoreLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localUid = prefs.getString('local_uid');
      
      if (localUid != null) {
        debugPrint("DEBUG: Restoring session from local UID: $localUid");
        await _loadUserProfile(localUid);
      } else {
        // Fallback for real firebase auth if present
        final authUid = await _getFirebaseUid();
        if (authUid != null) {
          await _loadUserProfile(authUid);
        }
      }
    } catch (e) {
      debugPrint("DEBUG: Error session restoration: $e");
    }
  }

  Future<String?> _getFirebaseUid() async {
    // This is a partial fallback for когда Firebase Auth finally logs them in
    return null; // For No-Auth flow, we primarily rely on local_uid
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final user = await ref.read(userRepositoryProvider).getUser(uid);
      if (user != null) {
        state = user;
        debugPrint("DEBUG: Restored user profile for ${user.name}");
      }
    } catch (e) {
      debugPrint("DEBUG: Error loading profile for $uid: $e");
    }
  }

  void setUser(UserEntity user) {
    state = user;
  }

  Future<void> updateName(String newName) async {
    if (state == null) return;
    final updated = state!.copyWith(name: newName);
    await ref.read(userRepositoryProvider).updateUser(updated);
    state = updated;
  }


  Future<void> updateUsername(String newUsername) async {
    if (state == null) return;
    // Generate public URL when username is set
    final publicUrl = 'https://linkmeup.app/${newUsername.toLowerCase()}';
    final updated = state!.copyWith(
      username: newUsername.toLowerCase(),
      publicUrl: publicUrl,
    );
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


  Future<void> addSocialLink(SocialLinkEntity link) async {
    if (state == null) return;
    
    // Add to local state first for responsiveness
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.add(link);
    state = state!.copyWith(socialLinks: currentLinks);

    // Persist to Firestore
    await ref.read(userRepositoryProvider).addSocialLink(state!.uid, link);
  }

  Future<void> removeSocialLink(String id) async {
    if (state == null) return;
    
    final currentLinks = List<SocialLinkEntity>.from(state!.socialLinks);
    currentLinks.removeWhere((l) => l.id == id);
    state = state!.copyWith(socialLinks: currentLinks);
    
    await ref.read(userRepositoryProvider).deleteSocialLink(state!.uid, id);
  }

  Future<void> toggleSocialVisibility(String id) async {
    if (state == null) return;
    
    SocialLinkEntity? targetLink;
    final currentLinks = state!.socialLinks.map((link) {
      if (link.id == id) {
        targetLink = link.copyWith(isVisible: !link.isVisible);
        return targetLink!;
      }
      return link;
    }).toList();
    
    state = state!.copyWith(socialLinks: currentLinks);
    
    if (targetLink != null) {
      await ref.read(userRepositoryProvider).updateSocialLink(state!.uid, targetLink!);
    }
  }

  Future<void> updateSocialLinks(List<SocialLinkEntity> links) async {
    if (state == null) return;
    
    state = state!.copyWith(socialLinks: links);
    
    // Persist the entire list to maintain order in Firestore
    await ref.read(userRepositoryProvider).updateSocialLinks(state!.uid, links);
  }

  Future<void> markQrAsGenerated() async {
    if (state == null) return;
    state = state!.copyWith(isQrGenerated: true, qrGeneratedAt: DateTime.now());
    await ref.read(userRepositoryProvider).markQrAsGenerated(state!.uid);
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_uid');
      state = null;
      debugPrint("DEBUG: Local session cleared on sign out.");
    } catch (e) {
      debugPrint("DEBUG: Error during sign out: $e");
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, UserEntity?>(() {
  return UserNotifier();
});
