class ContentApiConfig {
  const ContentApiConfig({
    required this.enabled,
    required this.provider,
    this.baseUri,
    this.token,
    this.manifestPath,
    this.bundlePath,
    this.detailBundlePath,
  });

  const ContentApiConfig.disabled()
      : enabled = false,
        provider = 'generic',
        baseUri = null,
        token = null,
        manifestPath = null,
        bundlePath = null,
        detailBundlePath = null;

  factory ContentApiConfig.fromEnvironment() {
    const enabled = bool.fromEnvironment('SAKINAH_CONTENT_API_ENABLED');
    const provider = String.fromEnvironment('SAKINAH_CONTENT_API_PROVIDER');
    const baseUrl = String.fromEnvironment('SAKINAH_CONTENT_API_BASE_URL');
    const token = String.fromEnvironment('SAKINAH_CONTENT_API_TOKEN');
    const manifestPath =
        String.fromEnvironment('SAKINAH_CONTENT_MANIFEST_PATH');
    const bundlePath = String.fromEnvironment('SAKINAH_CONTENT_BUNDLE_PATH');
    const detailBundlePath =
        String.fromEnvironment('SAKINAH_CONTENT_DETAIL_BUNDLE_PATH');

    return ContentApiConfig(
      enabled: enabled,
      provider: provider.trim().isEmpty ? 'generic' : provider.trim(),
      baseUri: _uriFromEnvironment(baseUrl),
      token: token.trim().isEmpty ? null : token.trim(),
      manifestPath: manifestPath.trim().isEmpty ? '/manifest' : manifestPath,
      bundlePath: bundlePath.trim().isEmpty ? null : bundlePath,
      detailBundlePath:
          detailBundlePath.trim().isEmpty ? null : detailBundlePath,
    );
  }

  final bool enabled;
  final String provider;
  final Uri? baseUri;
  final String? token;
  final String? manifestPath;
  final String? bundlePath;
  final String? detailBundlePath;

  bool get isUsable => enabled && baseUri != null;
}

Uri? _uriFromEnvironment(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }
  return uri;
}
