import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/themes/app_colors.dart';

enum SocialPlatform {
  instagram,
  twitter, // Now X
  linkedin,
  snapchat,
  whatsapp,
  tiktok,
  youtube,
  facebook,
  discord,
  pinterest,
  reddit,
  telegram,
  github,
  other;

  String get displayName {
    switch (this) {
      case SocialPlatform.twitter:
        return 'X (Twitter)';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  IconData get icon {
    switch (this) {
      case SocialPlatform.instagram:
        return FontAwesomeIcons.instagram;
      case SocialPlatform.twitter:
        return FontAwesomeIcons.xTwitter;
      case SocialPlatform.linkedin:
        return FontAwesomeIcons.linkedin;
      case SocialPlatform.snapchat:
        return FontAwesomeIcons.snapchat;
      case SocialPlatform.whatsapp:
        return FontAwesomeIcons.whatsapp;
      case SocialPlatform.tiktok:
        return FontAwesomeIcons.tiktok;
      case SocialPlatform.youtube:
        return FontAwesomeIcons.youtube;
      case SocialPlatform.facebook:
        return FontAwesomeIcons.facebook;
      case SocialPlatform.discord:
        return FontAwesomeIcons.discord;
      case SocialPlatform.pinterest:
        return FontAwesomeIcons.pinterest;
      case SocialPlatform.reddit:
        return FontAwesomeIcons.reddit;
      case SocialPlatform.telegram:
        return FontAwesomeIcons.telegram;
      case SocialPlatform.github:
        return FontAwesomeIcons.github;
      case SocialPlatform.other:
        return FontAwesomeIcons.link;
    }
  }

  Color get color {
    switch (this) {
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C); // Official Insta Pink/Orange
      case SocialPlatform.twitter:
        return AppColors.twitter;
      case SocialPlatform.linkedin:
        return AppColors.linkedin;
      case SocialPlatform.snapchat:
        return AppColors.snapchat;
      case SocialPlatform.whatsapp:
        return AppColors.whatsapp;
      case SocialPlatform.tiktok:
        return AppColors.tiktok;
      case SocialPlatform.youtube:
        return AppColors.youtube;
      case SocialPlatform.facebook:
        return AppColors.facebook;
      case SocialPlatform.discord:
        return AppColors.discord;
      case SocialPlatform.pinterest:
        return AppColors.pinterest;
      case SocialPlatform.reddit:
        return AppColors.reddit;
      case SocialPlatform.telegram:
        return AppColors.telegram;
      case SocialPlatform.github:
        return const Color(0xFF333333);
      case SocialPlatform.other:
        return AppColors.primaryPurple;
    }
  }
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
