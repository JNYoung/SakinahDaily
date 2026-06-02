import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/backend_api_config.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/services/remote_content_api_client.dart';
import 'package:sakinah_daily/core/services/remote_prayer_location_api_client.dart';

import 'support/fake_content_http_client.dart';

void main() {
  test('disabled backend config produces no prayer location client', () {
    final container = ProviderContainer(
      overrides: [
        backendApiConfigProvider.overrideWithValue(
          const BackendApiConfig.disabled(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(remotePrayerLocationClientProvider), isNull);
  });

  test('city search parses backend mock locations into prayer presets',
      () async {
    final http = FakeContentHttpClient({
      _citiesUri(query: 'jakarta', locale: 'id', limit: 5).toString():
          ContentHttpResponse.ok(_citiesJson()),
    });
    final client = _client(http);

    final cities = await client.searchCities(
      query: 'jakarta',
      locale: 'id',
      limit: 5,
    );

    expect(cities, hasLength(1));
    expect(cities.single.id, 'id-jakarta');
    expect(cities.single.label, 'Jakarta');
    expect(cities.single.latitude, -6.2088);
    expect(cities.single.longitude, 106.8456);
    expect(cities.single.timezoneId, 'Asia/Jakarta');
    expect(cities.single.method, 'indonesia');
    expect(http.requests.single.uri,
        _citiesUri(query: 'jakarta', locale: 'id', limit: 5));
  });

  test('city search sends backend authorization token when configured',
      () async {
    final http = FakeContentHttpClient({
      _citiesUri(locale: 'en').toString():
          ContentHttpResponse.ok(jsonEncode({'results': []})),
    });
    final client = _client(http, token: 'backend-token');

    await client.searchCities(locale: 'en');

    expect(
        http.requests.single.headers['Authorization'], 'Bearer backend-token');
  });

  test('resolve city posts city id and parses prayer-ready location', () async {
    final http = FakeContentHttpClient({
      _resolveUri().toString(): ContentHttpResponse.ok(_resolvedCityJson()),
    });
    final client = _client(http);

    final preset = await client.resolveCity(
      cityId: 'ae-dubai',
      locale: 'en',
    );

    expect(preset, isNotNull);
    expect(preset!.id, 'ae-dubai');
    expect(preset.timezoneId, 'Asia/Dubai');
    expect(preset.method, 'muslim_world_league');
    expect(http.requests.single.method, 'POST');
    expect(http.requests.single.body, {
      'cityId': 'ae-dubai',
      'locale': 'en',
    });
  });
}

HttpRemotePrayerLocationClient _client(
  ContentHttpClient http, {
  String? token,
}) {
  return HttpRemotePrayerLocationClient(
    config: BackendApiConfig(
      enabled: true,
      baseUri: Uri.parse('https://backend.example.test'),
      token: token,
    ),
    httpClient: http,
  );
}

Uri _citiesUri({
  String query = '',
  String locale = 'en',
  int limit = 50,
}) {
  return Uri.parse('https://backend.example.test/locations/cities').replace(
    queryParameters: {
      if (query.isNotEmpty) 'query': query,
      'locale': locale,
      'limit': '$limit',
    },
  );
}

Uri _resolveUri() {
  return Uri.parse('https://backend.example.test/locations/resolve');
}

String _citiesJson() {
  return jsonEncode({
    'results': [
      {
        'id': 'id-jakarta',
        'label': 'Jakarta',
        'countryCode': 'ID',
        'countryName': 'Indonesia',
        'coordinates': {
          'latitude': -6.2088,
          'longitude': 106.8456,
        },
        'timezone': 'Asia/Jakarta',
        'prayerCalculationMethod': 'indonesia',
        'source': 'mvp_curated_city_catalog',
      }
    ],
  });
}

String _resolvedCityJson() {
  return jsonEncode({
    'id': 'ae-dubai',
    'label': 'Dubai',
    'countryCode': 'AE',
    'countryName': 'United Arab Emirates',
    'coordinates': {
      'latitude': 25.2048,
      'longitude': 55.2708,
    },
    'timezone': 'Asia/Dubai',
    'prayerCalculationMethod': 'muslim_world_league',
    'source': 'mvp_curated_city_catalog',
    'resolution': 'city_id',
  });
}
