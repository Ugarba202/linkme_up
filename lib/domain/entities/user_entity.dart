import 'dart:typed_data';
import 'social_link_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String username;
  final String country;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final String? bannerUrl;
  final String bio;
  final String? publicUrl;
  final bool profileCompleted;
  final List<SocialLinkEntity> socialLinks;
  final int views;
  final int clicks;
  final String email;
  final String phoneNumber;
  final bool isQrGenerated;
  final DateTime? qrGeneratedAt;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.name,
    this.username = '',
    this.country = 'Nigeria',
    this.photoUrl,
    this.photoBytes,
    this.bannerUrl,
    this.bio = '',
    this.socialLinks = const [],
    this.publicUrl,
    this.profileCompleted = false,
    this.views = 0,
    this.clicks = 0,
    this.isQrGenerated = false,
    this.qrGeneratedAt,
    required this.createdAt,
    this.email = '',
    this.phoneNumber = '',
  });

  UserEntity copyWith({
    String? uid,
    String? name,
    String? username,
    String? country, 
    String? photoUrl,
    Uint8List? photoBytes,
    String? bannerUrl,
    String? bio,
    List<SocialLinkEntity>? socialLinks,
    String? publicUrl,
    bool? profileCompleted,
    DateTime? createdAt,
    String? email,
    String? phoneNumber,
    int? views,
    int? clicks,
    bool? isQrGenerated,
    DateTime? qrGeneratedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBytes: photoBytes ?? this.photoBytes,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      publicUrl: publicUrl ?? this.publicUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      isQrGenerated: isQrGenerated ?? this.isQrGenerated,
      qrGeneratedAt: qrGeneratedAt ?? this.qrGeneratedAt,
    );
  }
}
