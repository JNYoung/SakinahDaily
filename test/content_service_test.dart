import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';

void main() {
  late ContentService service;

  setUp(() {
    service = ContentService(
      seedRepository: SeedContentRepository(SeedContent.demo()),
      cacheRepository: ContentCacheRepository(InMemoryContentCacheStore()),
    );
  });

  test('seed home loads offline', () {
    expect(service.loadHomeContent(), isNotEmpty);
  });

  test('seed push deep link loads offline', () async {
    final result = await service.recoverPushDeepLink('session_morning_ease');

    expect(result.available, isTrue);
  });

  test('hash mismatch discards bundle', () async {
    const ref = BundleRef(
      id: 'bundle-home',
      url: 'memory://bundle-home',
      sha256: 'wrong',
      schemaVersion: 1,
    );

    final accepted =
        await service.validateAndCacheBundle(ref, _approvedBundleJson());

    expect(accepted, isFalse);
  });

  test('unsupported schema discards bundle', () async {
    final raw = _approvedBundleJson(schemaVersion: 2);
    final ref = BundleRef(
      id: 'bundle-home',
      url: 'memory://bundle-home',
      sha256: sha256.convert(utf8.encode(raw)).toString(),
      schemaVersion: 2,
    );

    expect(await service.validateAndCacheBundle(ref, raw), isFalse);
  });

  test('unapproved bundle is rejected', () async {
    final raw = _approvedBundleJson(reviewStatus: 'draft');
    final ref = BundleRef(
      id: 'bundle-home',
      url: 'memory://bundle-home',
      sha256: sha256.convert(utf8.encode(raw)).toString(),
      schemaVersion: 1,
    );

    expect(await service.validateAndCacheBundle(ref, raw), isFalse);
  });

  test('women privacy filter blocks sensitive lock-screen content', () {
    final items = service.lockScreenSafeSourceItems(
      const ContentRequestContext(
        languageCode: 'en',
        womenIbadahMode: WomenIbadahMode(enabled: true),
        lockScreenSafe: true,
      ),
    );

    expect(items.any((item) => item.cycleSensitiveHidden), isFalse);
  });

  test('audio hash mismatch returns text-only fallback', () {
    const asset = AudioAsset(
      id: 'audio',
      reciterName: 'Approved reciter',
      bgmAllowed: false,
      approved: true,
      sha256: 'expected',
    );

    expect(service.audioHashValidOrTextFallback(asset, 'actual'), isFalse);
  });
}

String _approvedBundleJson({
  int schemaVersion = 1,
  String status = 'published',
  String reviewStatus = 'approved',
}) {
  return jsonEncode({
    'id': 'bundle-home',
    'schemaVersion': schemaVersion,
    'status': status,
    'reviewStatus': reviewStatus,
    'payload': {'kind': 'home'},
  });
}
