import 'dart:typed_data';
import 'social_link_entity.dart';

class UserEntity {
  final String uid;
  final String name;
  final String? username;
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
    this.username,
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

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'full_name': name,
      'username': username,
      'country': country,
      'avatar_url': photoUrl,
      'banner_url': bannerUrl,
      'bio': bio,
      'public_url': publicUrl,
      'profile_completed': profileCompleted,
      'email': email,
      'phone_number': phoneNumber,
      'views': views,
      'clicks': clicks,
      'is_qr_generated': isQrGenerated,
      'qr_generated_at': qrGeneratedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map, {List<SocialLinkEntity> links = const []}) {
    return UserEntity(
      uid: map['id'],
      name: map['full_name'] ?? '',
      username: map['username'], // Allow null
      country: map['country'] ?? 'Nigeria',
      photoUrl: map['avatar_url'],
      bannerUrl: map['banner_url'],
      bio: map['bio'] ?? '',
      publicUrl: map['public_url'],
      profileCompleted: map['profile_completed'] ?? false,
      socialLinks: links,
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      isQrGenerated: map['is_qr_generated'] ?? false,
      qrGeneratedAt: map['qr_generated_at'] != null ? DateTime.parse(map['qr_generated_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
