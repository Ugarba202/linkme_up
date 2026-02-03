import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/social_link_entity.dart';

class FirestoreUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(UserEntity user) async {
    final batch = _firestore.batch();

    // User document
    final userRef = _firestore.collection('users').doc(user.uid);
    batch.set(userRef, {
      'uid': user.uid,
      'name': user.name,
      'username': user.username,
      'email': user.email,
      'country': user.country,
      'photoUrl': user.photoUrl,
      'bannerUrl': user.bannerUrl,
      'bio': user.bio,
      'publicUrl': user.publicUrl,
      'profileCompleted': user.profileCompleted,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Username lookup table
    final usernameRef = _firestore.collection('usernames').doc(user.username.toLowerCase());
    batch.set(usernameRef, {'uid': user.uid});

    await batch.commit();

    // Add social links if any
    if (user.socialLinks.isNotEmpty) {
      for (final link in user.socialLinks) {
        await addSocialLink(user.uid, link);
      }
    }
  }

  @override
  Future<void> addSocialLink(String uid, SocialLinkEntity link) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('social_links')
        .doc(link.id.isEmpty ? null : link.id)
        .set({
      'platform': link.platform.name,
      'username': link.username,
      'url': link.url,
      'isVisible': link.isVisible,
      'order': link.order,
      'createdAt': link.createdAt,
    });
  }

  @override
  Future<void> updateSocialLink(String uid, SocialLinkEntity link) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('social_links')
        .doc(link.id)
        .update({
      'platform': link.platform.name,
      'username': link.username,
      'url': link.url,
      'isVisible': link.isVisible,
      'order': link.order,
    });
  }

  @override
  Future<void> deleteSocialLink(String uid, String linkId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('social_links')
        .doc(linkId)
        .delete();
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;

    // Fetch social links from subcollection
    final linksSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('social_links')
        .orderBy('order')
        .get();

    final links = linksSnapshot.docs.map((d) {
      final linkData = d.data();
      return SocialLinkEntity(
        id: d.id,
        platform: SocialPlatform.values.firstWhere(
          (e) => e.name == linkData['platform'],
          orElse: () => SocialPlatform.other,
        ),
        username: linkData['username'] ?? '',
        url: linkData['url'] ?? '',
        isVisible: linkData['isVisible'] ?? true,
        order: linkData['order'] ?? 0,
        createdAt: (linkData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();

    return UserEntity(
      uid: uid,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      country: data['country'] ?? 'Nigeria',
      photoUrl: data['photoUrl'],
      bannerUrl: data['bannerUrl'],
      bio: data['bio'] ?? '',
      publicUrl: data['publicUrl'],
      profileCompleted: data['profileCompleted'] ?? false,
      socialLinks: links,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: data['phoneNumber'],
    );
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.uid);

    // Get old username to handle change in lookup table if necessary
    // Note: In many systems, username changes are restricted. 
    // For now, updating the main fields.
    
    batch.update(userRef, {
      'name': user.name,
      'username': user.username,
      'bio': user.bio,
      'photoUrl': user.photoUrl,
      'bannerUrl': user.bannerUrl,
      'country': user.country,
      'publicUrl': user.publicUrl,
      'profileCompleted': user.profileCompleted,
    });

    await batch.commit();
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _firestore
        .collection('usernames')
        .doc(username.toLowerCase())
        .get();
    return !doc.exists;
  }
}
