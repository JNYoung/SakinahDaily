# Client Content Cache Implementation

The MVP client content runtime keeps seed content as the always-available fallback, then overlays locally cached, validated bundles when they exist. It does not call a live CMS, download a full Quran corpus, or generate religious source content.

## Cache Layers

1. Bundled seed content from the local repository.
2. Active content manifest stored through `ContentCacheRepository`.
3. Approved bundle entries stored through `ContentCacheStore`.

The app uses `SharedPreferencesContentCacheStore` for MVP persistence. Tests use `InMemoryContentCacheStore`, so no platform filesystem or live service is required.

## Manifest And Bundle Validation

Manifests can carry schema version, language, market, source corpus versions, revoked content ids, expiry, and fallback settings.

Bundles are activated only after:

- SHA-256 hash matches the manifest reference.
- Bundle and reference schema versions match the supported client schema.
- Bundle status is `published`.
- Bundle review status is `approved`.
- Language and market match the current request context.
- Bundle id is not revoked.

Failed bundles are discarded and do not partially activate.

## Content Filtering

Cached bundle payloads can include `dailySessions`, `sourceItems`, `quranAyahs`, `duas`, and `dhikrs`. Each item must still be `published` and `approved`; draft, in-review, rejected, and revoked items are hidden.

If no cached content exists for a type, the client falls back to approved seed content. Revocation wins over both cache and seed.

## Stale And Offline Behavior

Expired manifests disable cached bundle reads unless fallback config explicitly allows stale content within `maxStaleSeconds`. When no manifest or bundle is available, seed content remains available.

## Push Deep-Link Recovery

Local push opens local content first. If a daily-session push is missing locally and carries a `bundleHint`, tests can use a fake `RemoteManifestClient` to resolve and download a detail bundle. The bundle is still hash/schema/approval validated before the route becomes available.

If the hinted bundle is unavailable or invalid, the receiver returns the safe missing-content fallback and does not invent content.

## Future Work

- File or SQLite-backed bundle cache for larger payloads.
- Real CMS/API manifest client.
- CDN-hosted bundle downloads.
- Offline audio cache and licensed audio validation.
- Full Quran/surah bundle strategy.
- Production FCM/APNs delivery and token handling.
