import 'social_link_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String username;
  final String? phoneNumber;
  final String email;
  final String country;
  final String? photoUrl;
  final String? bannerUrl;
  final String bio;
  final String? publicUrl;
  final bool profileCompleted;
  final List<SocialLinkEntity> socialLinks;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.name,
    this.username = '',
    this.phoneNumber,
    required this.email,
    this.country = 'Nigeria',
    this.photoUrl,
    this.bannerUrl,
    this.bio = '',
    this.socialLinks = const [],
    this.publicUrl,
    this.profileCompleted = false,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    
    String? name,
    String? username,
    String? phoneNumber,
    String? email,
    String? country, 
    String? photoUrl,
    String? bannerUrl,
    String? bio,
    List<SocialLinkEntity>? socialLinks,
    String? publicUrl,
    bool? profileCompleted,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      publicUrl: publicUrl ?? this.publicUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
