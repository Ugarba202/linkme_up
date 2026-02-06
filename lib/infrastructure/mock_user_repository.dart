import '../domain/entities/social_link_entity.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/user_repository.dart';

class MockUserRepository implements IUserRepository {
  final Map<String, UserEntity> _users = {};
  
  @override
  Future<void> createUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users[user.uid] = user;
    print("MOCK: Created user ${user.username}");
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users[uid];
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(user.uid)) {
      _users[user.uid] = user;
      print("MOCK: Updated user ${user.uid}");
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simple check: unavailable if 'taken' is in the name, otherwise available
    return !username.toLowerCase().contains('taken'); 
  }

  @override
  Future<void> addSocialLink(String uid, SocialLinkEntity link) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      final updatedLinks = List<SocialLinkEntity>.from(user.socialLinks)..add(link);
      _users[uid] = user.copyWith(socialLinks: updatedLinks);
      print("MOCK: Added social link ${link.platform.name}");
    }
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
       final user = _users[uid]!;
       final updatedLinks = user.socialLinks.map((l) => l.id == link.id ? link : l).toList();
       _users[uid] = user.copyWith(socialLinks: updatedLinks);
       print("MOCK: Updated social link ${link.platform.name}");
    }
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
       final user = _users[uid]!;
       final updatedLinks = user.socialLinks.where((l) => l.id != linkId).toList();
       _users[uid] = user.copyWith(socialLinks: updatedLinks);
       print("MOCK: Deleted social link $linkId");
    }
  }
}
