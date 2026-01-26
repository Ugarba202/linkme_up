
enum SocialPlatform {
  instagram,
  twitter,
  linkedin,
  snapchat,
  whatsapp,
  tiktok,
  youtube,
  github,
  other
}

class SocialLinkEntity {
  final String id;
  final SocialPlatform platform;
  final String username;
  final String url;
  final bool isVisible;

  SocialLinkEntity({
    required this.id,
    required this.platform,
    required this.username,
    required this.url,
    this.isVisible = true,
  });

  SocialLinkEntity copyWith({
    String? id,
    SocialPlatform? platform,
    String? username,
    String? url,
    bool? isVisible,
  }) {
    return SocialLinkEntity(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      username: username ?? this.username,
      url: url ?? this.url,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
