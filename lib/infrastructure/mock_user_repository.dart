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
      // Generate a mock ID if not present
      final finalLink = link.id.isEmpty 
          ? link.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : link;
          
      final updatedLinks = List<SocialLinkEntity>.from(user.socialLinks)
        ..add(finalLink);
      _users[uid] = user.copyWith(socialLinks: updatedLinks);
      print("MOCK: Added social link ${finalLink.platform.name} with ID ${finalLink.id}");
    }
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      final updatedLinks = user.socialLinks
          .map((l) => l.id == link.id ? link : l)
          .toList();
      _users[uid] = user.copyWith(socialLinks: updatedLinks);
      print("MOCK: Updated social link ${link.platform.name}");
    }
  }

  @override
  Future<void> updateSocialLinks(
    String uid,
    List<SocialLinkEntity> links,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      _users[uid] = user.copyWith(socialLinks: links);
      print("MOCK: Updated social links order for $uid");
    }
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      final updatedLinks = user.socialLinks
          .where((l) => l.id != linkId)
          .toList();
      _users[uid] = user.copyWith(socialLinks: updatedLinks);
      print("MOCK: Deleted social link $linkId");
    }
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _users.values.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> incrementClicks(String uid) {
    // TODO: implement incrementClicks
    throw UnimplementedError();
  }

  @override
  Future<void> incrementViews(String uid) {
    // TODO: implement incrementViews
    throw UnimplementedError();
  }

  @override
  Future<void> markQrAsGenerated(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(uid)) {
      final user = _users[uid]!;
      _users[uid] = user.copyWith(
        isQrGenerated: true,
        qrGeneratedAt: DateTime.now(),
      );
      print("MOCK: Marked QR as generated for $uid");
    }
  }
}
