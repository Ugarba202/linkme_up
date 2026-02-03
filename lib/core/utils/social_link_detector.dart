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
    if (lower.contains('snapchat.com')) {
      return SocialPlatform.snapchat;
    }
    if (lower.contains('whatsapp.com') || lower.contains('wa.me')) {
      return SocialPlatform.whatsapp;
    }
    if (lower.contains('tiktok.com')) {
      return SocialPlatform.tiktok;
    }
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return SocialPlatform.youtube;
    }
    if (lower.contains('facebook.com') || lower.contains('fb.com')) {
      return SocialPlatform.facebook;
    }
    if (lower.contains('discord.com') || lower.contains('discord.gg')) {
      return SocialPlatform.discord;
    }
    if (lower.contains('pinterest.com') || lower.contains('pin.it')) {
      return SocialPlatform.pinterest;
    }
    if (lower.contains('reddit.com')) {
      return SocialPlatform.reddit;
    }
    if (lower.contains('t.me') || lower.contains('telegram.me')) {
      return SocialPlatform.telegram;
    }
    if (lower.contains('github.com')) {
      return SocialPlatform.github;
    }

    return SocialPlatform.other;
  }

  static String extractUsername(String url, SocialPlatform platform) {
    if (platform == SocialPlatform.other) return url;

    try {
      String cleanUrl = url.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }

      final uri = Uri.parse(cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl');
      if (uri.pathSegments.isNotEmpty) {
        if (platform == SocialPlatform.youtube && uri.pathSegments.contains('watch')) {
          return uri.queryParameters['v'] ?? 'video';
        }
        return uri.pathSegments.last;
      }
    } catch (_) {
      // Fallback
    }

    return url;
  }

  static List<SocialLinkEntity> detectAll(String input) {
    if (input.isEmpty) return [];

    // Split by common delimiters: space, newline, comma
    final parts = input.split(RegExp(r'[\s,\n]+'));
    final List<SocialLinkEntity> results = [];
    final Set<SocialPlatform> detectedPlatforms = {};

    for (var part in parts) {
      if (part.trim().isEmpty) continue;

      final platform = detect(part);
      if (platform != SocialPlatform.other && !detectedPlatforms.contains(platform)) {
        detectedPlatforms.add(platform);
        results.add(SocialLinkEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}${platform.name}',
          platform: platform,
          username: extractUsername(part, platform),
          url: part.trim(),
          isVisible: true,
          createdAt: DateTime.now(),
        ));
      } else if (part.startsWith('http') && platform == SocialPlatform.other) {
        results.add(SocialLinkEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}other',
          platform: SocialPlatform.other,
          username: 'Link',
          url: part.trim(),
          isVisible: true,
          createdAt: DateTime.now(),
        ));
      }
    }
    return results;
  }
}
