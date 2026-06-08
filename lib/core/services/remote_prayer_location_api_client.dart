import 'dart:convert';

import '../config/backend_api_config.dart';
import '../models/sakinah_models.dart';
import 'remote_content_api_client.dart';

abstract class PrayerLocationCatalogClient {
  Future<List<PrayerLocationPreset>> searchCities({
    String query = '',
    String? country,
    required String locale,
    int limit = 50,
  });

  Future<PrayerLocationPreset?> resolveCity({
    required String cityId,
    required String locale,
  });
}

class RemotePrayerLocationException implements Exception {
  const RemotePrayerLocationException(
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
    return 'RemotePrayerLocationException: $message$status$endpoint';
  }
}

class HttpRemotePrayerLocationClient implements PrayerLocationCatalogClient {
  HttpRemotePrayerLocationClient({
    required this.config,
    required this.httpClient,
  });

  final BackendApiConfig config;
  final ContentHttpClient httpClient;

  @override
  Future<List<PrayerLocationPreset>> searchCities({
    String query = '',
    String? country,
    required String locale,
    int limit = 50,
  }) async {
    _ensureUsable();
    final queryParameters = <String, String>{
      if (query.trim().isNotEmpty) 'query': query.trim(),
      if (country != null && country.trim().isNotEmpty)
        'country': country.trim().toUpperCase(),
      'locale': _safeLocale(locale),
      'limit': '$limit',
    };
    final uri = _endpointUri(
      '/locations/cities',
      queryParameters: queryParameters,
    );
    final response = await httpClient.get(uri, headers: _headers());
    _throwIfFailed(response, uri);
    final decoded = _decodeObject(response.body);
    final results = decoded['results'];
    if (results is! List) {
      return const [];
    }
    return [
      for (final item in results)
        if (item is Map) _presetFromJson(_stringKeyedMap(item)),
    ];
  }

  @override
  Future<PrayerLocationPreset?> resolveCity({
    required String cityId,
    required String locale,
  }) async {
    _ensureUsable();
    final uri = _endpointUri('/locations/resolve');
    final response = await httpClient.postJson(
      uri,
      body: {
        'cityId': cityId,
        'locale': _safeLocale(locale),
      },
      headers: _headers(),
    );
    if (response.statusCode == 404 || response.statusCode == 422) {
      return null;
    }
    _throwIfFailed(response, uri);
    return _presetFromJson(_decodeObject(response.body));
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
      throw const RemotePrayerLocationException(
        'Backend API is disabled or missing base URI.',
      );
    }
  }

  Uri _endpointUri(
    String path, {
    Map<String, String> queryParameters = const {},
  }) {
    final baseUri = config.baseUri;
    if (baseUri == null) {
      throw const RemotePrayerLocationException(
        'Backend API is disabled or missing base URI.',
      );
    }
    return _joinBaseUri(baseUri, path).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
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
    throw RemotePrayerLocationException(
      'Backend API location request failed.',
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
      return _stringKeyedMap(decoded);
    }
    throw const RemotePrayerLocationException(
      'Backend API response was not a JSON object.',
    );
  }

  PrayerLocationPreset _presetFromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'];
    if (coordinates is! Map) {
      throw const RemotePrayerLocationException(
        'Location response is missing coordinates.',
      );
    }
    final keyedCoordinates = _stringKeyedMap(coordinates);
    return PrayerLocationPreset(
      id: json['id'] as String,
      label: json['label'] as String,
      latitude: (keyedCoordinates['latitude'] as num).toDouble(),
      longitude: (keyedCoordinates['longitude'] as num).toDouble(),
      timezoneId: json['timezone'] as String,
      method: json['prayerCalculationMethod'] as String,
    );
  }

  Map<String, dynamic> _stringKeyedMap(Map<dynamic, dynamic> input) {
    return input.map((key, value) => MapEntry('$key', value));
  }

  String _safeLocale(String locale) {
    return switch (locale) {
      'id' || 'ar' => locale,
      _ => 'en',
    };
  }
}
