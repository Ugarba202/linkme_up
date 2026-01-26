import '../../domain/entities/social_link_entity.dart';

class SocialLinkDetector {
  static SocialPlatform detect(String input) {
    final lower = input.toLowerCase();
    
    if (lower.contains('instagram.com') || lower.contains('ig.me')) {
      return SocialPlatform.instagram;
    }
    if (lower.contains('twitter.com') || lower.contains('x.com')) {
      return SocialPlatform.twitter;
    }
    if (lower.contains('linkedin.com')) {
      return SocialPlatform.linkedin;
    }
    if (lower.contains('facebook.com') || lower.contains('fb.com')) {
       // Added for completeness even if not in original enum, but let's stick to the enum
       return SocialPlatform.other;
    }
    if (lower.contains('github.com')) {
      return SocialPlatform.github;
    }
    if (lower.contains('tiktok.com')) {
      return SocialPlatform.tiktok;
    }
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return SocialPlatform.youtube;
    }
    if (lower.contains('whatsapp.com') || lower.contains('wa.me')) {
      return SocialPlatform.whatsapp;
    }
    if (lower.contains('snapchat.com')) {
      return SocialPlatform.snapchat;
    }
    
    return SocialPlatform.other;
  }

  static String extractUsername(String url, SocialPlatform platform) {
    if (platform == SocialPlatform.other) return url;
    
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    
    return url;
  }
}
