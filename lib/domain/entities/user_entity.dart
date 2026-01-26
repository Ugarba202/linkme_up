import 'social_link_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String phoneNumber;
  final String? photoUrl;
  final List<SocialLinkEntity> socialLinks;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.photoUrl,
    this.socialLinks = const [],
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    List<SocialLinkEntity>? socialLinks,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
