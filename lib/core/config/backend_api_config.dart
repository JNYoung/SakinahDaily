class BackendApiConfig {
  const BackendApiConfig({
    required this.enabled,
    this.baseUri,
    this.token,
  });

  const BackendApiConfig.disabled()
      : enabled = false,
        baseUri = null,
        token = null;

  factory BackendApiConfig.fromEnvironment() {
    const enabled = bool.fromEnvironment('SAKINAH_BACKEND_API_ENABLED');
    const baseUrl = String.fromEnvironment('SAKINAH_BACKEND_API_BASE_URL');
    const token = String.fromEnvironment('SAKINAH_BACKEND_API_TOKEN');

    return BackendApiConfig(
      enabled: enabled,
      baseUri: _uriFromEnvironment(baseUrl),
      token: token.trim().isEmpty ? null : token.trim(),
    );
  }

  final bool enabled;
  final Uri? baseUri;
  final String? token;

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
