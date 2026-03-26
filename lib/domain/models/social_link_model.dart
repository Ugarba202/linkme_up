import 'package:flutter/material.dart';

class SocialLinkModel {
  final String id;
  final String platformName;
  final String urlOrUsername;
  final IconData icon;
  bool isVisible;

  SocialLinkModel({
    required this.id,
    required this.platformName,
    required this.urlOrUsername,
    required this.icon,
    this.isVisible = true,
  });
}
