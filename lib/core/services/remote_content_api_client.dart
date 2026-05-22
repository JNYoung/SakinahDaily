import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/content_api_config.dart';
import '../models/sakinah_models.dart';
import 'content_service.dart';

abstract class ContentHttpClient {
  Future<ContentHttpResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  });
}

class ContentHttpResponse {
  const ContentHttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  factory ContentHttpResponse.ok(
    String body, {
    Map<String, String> headers = const {},
  }) {
    return ContentHttpResponse(
      statusCode: 200,
      body: body,
      headers: headers,
    );
  }

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class DartHttpContentClient implements ContentHttpClient {
  DartHttpContentClient({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<ContentHttpResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.get(uri, headers: headers);
    return ContentHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
    );
  }

  void close() => _client.close();
}

class RemoteContentException implements Exception {
  const RemoteContentException(
    this.message, {
    this.uri,
    this.statusCode,
  });

  final String message;
  final Uri? uri;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' status=$statusCode';
    final endpoint = uri == null ? '' : ' uri=$uri';
    return 'RemoteContentException: $message$status$endpoint';
  }
}

class RemoteContentDisabledException extends RemoteContentException {
  const RemoteContentDisabledException()
      : super('Remote content API is disabled or missing base URI.');
}

class HttpRemoteManifestClient implements RemoteManifestClient {
  HttpRemoteManifestClient({
    required this.config,
    required this.httpClient,
    this.supportedSchemaVersion = 1,
  });

  final ContentApiConfig config;
  final ContentHttpClient httpClient;
  final int supportedSchemaVersion;

  ContentManifest? _lastManifest;
  ContentRequestContext? _lastContext;

  @override
  Future<ContentManifest> loadManifest(ContentRequestContext context) async {
    _ensureUsable();
    _lastContext = context;
    final uri = _endpointUri(
      config.manifestPath,
      '/manifest',
      queryParameters: {
        'app_version': context.appVersion ?? '0.1.0',
        'language': context.languageCode,
        'market': context.market,
        'schema_version': '$supportedSchemaVersion',
      },
    );
    final response = await httpClient.get(uri, headers: _headers());
    _throwIfFailed(response, uri);
    final manifest = ContentManifest.fromJson(_decodeObject(response.body));
    _lastManifest = manifest;
    return manifest;
  }

  @override
  Future<String> downloadBundle(BundleRef ref) async {
    _ensureUsable();
    final uri = _bundleUri(ref.url);
    final response = await httpClient.get(uri, headers: _headers());
    _throwIfFailed(response, uri);
    return response.body;
  }

  @override
  Future<BundleRef?> resolveBundleHint(String bundleHint) async {
    _ensureUsable();
    final detailPath = config.detailBundlePath;
    if (detailPath != null && detailPath.trim().isNotEmpty) {
      final context = _lastContext;
      final manifest = _lastManifest;
      final uri = _endpointUri(
        detailPath,
        '/detail-bundle',
        queryParameters: {
          'bundle_hint': bundleHint,
          'language': context?.languageCode ?? manifest?.language ?? 'en',
          'market': context?.market ?? manifest?.market ?? 'global',
          'schema_version': '$supportedSchemaVersion',
        },
      );
      final response = await httpClient.get(uri, headers: _headers());
      if (response.statusCode == 404) {
        return null;
      }
      _throwIfFailed(response, uri);
      return _bundleRefFromDetailResponse(response.body);
    }

    final bundles = _lastManifest?.bundles ?? const <BundleRef>[];
    for (final ref in bundles) {
      if (ref.id == bundleHint) {
        return ref;
      }
    }
    return null;
  }

  Map<String, String> _headers() {
    final token = config.token;
    if (token == null || token.isEmpty) {
      return const {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  void _ensureUsable() {
    if (!config.isUsable) {
      throw const RemoteContentDisabledException();
    }
  }

  Uri _endpointUri(
    String? configuredPath,
    String fallbackPath, {
    Map<String, String> queryParameters = const {},
  }) {
    final baseUri = config.baseUri;
    if (baseUri == null) {
      throw const RemoteContentDisabledException();
    }
    final path = (configuredPath == null || configuredPath.trim().isEmpty)
        ? fallbackPath
        : configuredPath.trim();
    final pathUri = Uri.tryParse(path);
    final uri = pathUri != null && pathUri.hasScheme
        ? pathUri
        : _joinBaseUri(baseUri, path);
    return uri.replace(queryParameters: queryParameters);
  }

  Uri _bundleUri(String url) {
    final parsed = Uri.parse(url);
    if (parsed.hasScheme) {
      return parsed;
    }
    final baseUri = config.baseUri;
    if (baseUri == null) {
      throw const RemoteContentDisabledException();
    }
    return _joinBaseUri(baseUri, url);
  }

  Uri _joinBaseUri(Uri baseUri, String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = baseUri.path.isEmpty
        ? '/'
        : (baseUri.path.endsWith('/') ? baseUri.path : '${baseUri.path}/');
    return baseUri.replace(
      path: cleanPath.isEmpty ? basePath : '$basePath$cleanPath',
      query: null,
      fragment: null,
    );
  }

  void _throwIfFailed(ContentHttpResponse response, Uri uri) {
    if (response.isSuccess) {
      return;
    }
    throw RemoteContentException(
      'Remote content request failed.',
      uri: uri,
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeObject(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    throw const RemoteContentException('Remote content response was not JSON.');
  }

  BundleRef? _bundleRefFromDetailResponse(String rawJson) {
    final decoded = _decodeObject(rawJson);
    final nested = decoded['bundleRef'] ?? decoded['bundle'];
    if (nested is Map<String, dynamic>) {
      return BundleRef.fromJson(nested);
    }
    if (nested is Map) {
      return BundleRef.fromJson(
        nested.map((key, value) => MapEntry('$key', value)),
      );
    }
    if (decoded.containsKey('bundleId') || decoded.containsKey('id')) {
      return BundleRef.fromJson(decoded);
    }
    return null;
  }
}
