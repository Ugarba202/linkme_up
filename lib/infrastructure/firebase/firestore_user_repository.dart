import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_link_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class FirestoreUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> createUser(UserEntity user) async {
    await _usersCollection.doc(user.uid).set(_userToMap(user));
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return _userFromMap(doc.data()!);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _usersCollection.doc(user.uid).update(_userToMap(user));
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  @override
  Future<UserEntity?> getUserByUsername(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return _userFromMap(query.docs.first.data());
  }

  @override
  Future<void> addSocialLink(String uid, SocialLinkEntity link) async {
    await _usersCollection.doc(uid).update({
      'socialLinks': FieldValue.arrayUnion([_linkToMap(link)]),
    });
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    final user = await getUser(uid);
    if (user == null) return;

    final updatedLinks = user.socialLinks
        .map((l) => l.id == link.id ? link : l)
        .toList();
    await _usersCollection.doc(uid).update({
      'socialLinks': updatedLinks.map((l) => _linkToMap(l)).toList(),
    });
  }

  @override
  Future<void> updateSocialLinks(
    String uid,
    List<SocialLinkEntity> links,
  ) async {
    await _usersCollection.doc(uid).update({
      'socialLinks': links.map((l) => _linkToMap(l)).toList(),
    });
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    final user = await getUser(uid);
    if (user == null) return;

    try {
      final targetLink = user.socialLinks.firstWhere((l) => l.id == linkId);
      await _usersCollection.doc(uid).update({
        'socialLinks': FieldValue.arrayRemove([_linkToMap(targetLink)]),
      });
    } catch (_) {
      // Link not found or already deleted
    }
  }

  @override
  Future<void> incrementViews(String uid) async {
    await _usersCollection.doc(uid).update({
      'views': FieldValue.increment(1),
    });
  }

  @override
  Future<void> incrementClicks(String uid) async {
    await _usersCollection.doc(uid).update({
      'clicks': FieldValue.increment(1),
    });
  }

  @override
  Future<void> markQrAsGenerated(String uid) async {
    await _usersCollection.doc(uid).update({
      'isQrGenerated': true,
      'qrGeneratedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mappers
  Map<String, dynamic> _userToMap(UserEntity user) {
    return {
      'uid': user.uid,
      'name': user.name,
      'username': user.username.toLowerCase(),
      'country': user.country,
      'photoUrl': user.photoUrl,
      'bannerUrl': user.bannerUrl,
      'bio': user.bio,
      'publicUrl': user.publicUrl,
      'profileCompleted': user.profileCompleted,
      'socialLinks': user.socialLinks.map((l) => _linkToMap(l)).toList(),
      'createdAt': Timestamp.fromDate(user.createdAt),
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'views': user.views,
      'clicks': user.clicks,
      'isQrGenerated': user.isQrGenerated,
      'qrGeneratedAt': user.qrGeneratedAt != null
          ? Timestamp.fromDate(user.qrGeneratedAt!)
          : null,
    };
  }

  UserEntity _userFromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      country: map['country'] ?? 'Nigeria',
      photoUrl: map['photoUrl'],
      bannerUrl: map['bannerUrl'],
      bio: map['bio'] ?? '',
      publicUrl: map['publicUrl'],
      profileCompleted: map['profileCompleted'] ?? false,
      socialLinks: (map['socialLinks'] as List? ?? [])
          .map((l) => _linkFromMap(l as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      isQrGenerated: map['isQrGenerated'] ?? false,
      qrGeneratedAt: (map['qrGeneratedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _linkToMap(SocialLinkEntity link) {
    return {
      'id': link.id,
      'platform': link.platform.name,
      'username': link.username,
      'url': link.url,
      'isVisible': link.isVisible,
      'order': link.order,
      'createdAt': Timestamp.fromDate(link.createdAt),
    };
  }

  SocialLinkEntity _linkFromMap(Map<String, dynamic> map) {
    return SocialLinkEntity(
      id: map['id'] ?? '',
      platform: SocialPlatform.values.firstWhere(
        (e) => e.name == (map['platform'] ?? 'other'),
        orElse: () => SocialPlatform.other,
      ),
      username: map['username'] ?? '',
      url: map['url'] ?? '',
      isVisible: map['isVisible'] ?? true,
      order: map['order'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

}
