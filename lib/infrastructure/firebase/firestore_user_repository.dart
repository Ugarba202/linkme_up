import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/social_link_entity.dart';

class FirestoreUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': user.name,
      'username': user.username,
      'email': user.email,
      'country': user.country,
      'photoUrl': user.photoUrl,
      'bannerUrl': user.bannerUrl,
      'bio': user.bio,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    
    // Fetch social links
    final linksSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('social_links')
        .get();
    
    final links = linksSnapshot.docs.map((d) {
      final linkData = d.data();
      return SocialLinkEntity(
        id: d.id,
        platform: SocialPlatform.values.firstWhere(
          (e) => e.name == linkData['platform'],
          orElse: () => SocialPlatform.other,
        ),
        username: linkData['username'],
        url: linkData['url'],
        isVisible: linkData['isVisible'] ?? true,
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
      socialLinks: links,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: data['phoneNumber'],
    );
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'name': user.name,
      'username': user.username,
      'bio': user.bio,
      'photoUrl': user.photoUrl,
      'bannerUrl': user.bannerUrl,
      'country': user.country,
    });
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }
}
