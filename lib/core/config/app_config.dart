class AppConfig {
  static const String baseUrl = 'linkmeup-95263.web.app';
  static const String scheme = 'https';
  
  // Legacy support for unpurchased custom domain
  static const String legacyUrl = 'linkmeup.app';

  static String get profileBaseUrl => '$scheme://$baseUrl';
}
