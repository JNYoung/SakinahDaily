# Remote Content API Integration

Date: 2026-05-21

## Architecture

The client now supports a remote content API behind the existing seed fallback
and persistent content cache.

Runtime flow:

1. `ContentService` restores any validated cached manifest and bundles.
2. When remote config is enabled and has a base URL, `HttpRemoteManifestClient`
   can fetch a manifest.
3. Required bundle refs from that manifest are downloaded as raw JSON.
4. `ContentService.validateAndCacheBundle` is the only activation path.
5. If manifest or bundle fetch fails, the app keeps using cached content or
   the built-in seed repository.

The HTTP layer does not decide whether religious content is displayable. It only
fetches JSON. Hash, schema, status, review status, language, market, and
revocation checks remain in `ContentService`.

## Local Scheduled Content Pack

`services/content-agent` now includes a local scheduled content-pack generator
that writes the same generic delivery shape consumed by the client:

```sh
cd services/content-agent
npm run content-pack:generate
npm run content-pack:serve
```

Local endpoints:

- `GET /manifest`
- `GET /bundles/<bundle_id>.json`
- `GET /detail-bundle?bundle_hint=<session_or_content_id>`

Dev mode can package the current seed content to prove downfeed wiring. Beta
mode blocks delivery until the source JSON contains approved reviewed inventory
with required counts, source labels, `version`, and `reviewedAt` metadata:

```sh
CONTENT_PACK_PROFILE=beta npm run content-pack:generate
```

The generator never creates Quran, Dua, Dhikr, Hadith, translations, or source
labels. It only packages approved source records.

## Configuration

Remote content is disabled by default. Enable it only with Dart environment
defines:

```sh
flutter run \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_PROVIDER=generic \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=https://content.example.test \
  --dart-define=SAKINAH_CONTENT_MANIFEST_PATH=/manifest \
  --dart-define=SAKINAH_CONTENT_DETAIL_BUNDLE_PATH=/detail-bundle
```

Supported keys:

- `SAKINAH_CONTENT_API_ENABLED`
- `SAKINAH_CONTENT_API_PROVIDER`
- `SAKINAH_CONTENT_API_BASE_URL`
- `SAKINAH_CONTENT_API_TOKEN`
- `SAKINAH_CONTENT_MANIFEST_PATH`
- `SAKINAH_CONTENT_BUNDLE_PATH`
- `SAKINAH_CONTENT_DETAIL_BUNDLE_PATH`

If `SAKINAH_CONTENT_API_ENABLED` is false or the base URL is absent/invalid, no
remote client is created and the app uses seed/cache behavior only. If the token
is empty, requests are unauthenticated. Tokens must never be logged or committed.

## Manifest Endpoint

The generic manifest endpoint receives:

- `app_version`
- `language`
- `market`
- `schema_version`

Expected JSON shape:

```json
{
  "manifestId": "manifest_en_global_001",
  "schemaVersion": 1,
  "language": "en",
  "market": "global",
  "generatedAt": "2026-05-21T00:00:00Z",
  "expiresAt": "2026-05-22T00:00:00Z",
  "sourceCorpusVersions": {
    "quran": "fixture-corpus-v1"
  },
  "revokedContentIds": [],
  "fallback": {
    "allowStale": true,
    "maxStaleSeconds": 604800
  },
  "bundles": []
}
```

## Bundle Endpoint

Bundle URLs come from manifest `BundleRef.url`. Absolute URLs are used directly;
relative URLs are resolved against the configured base URL.

Expected JSON shape:

```json
{
  "bundleId": "home_bundle_en_global_001",
  "bundleType": "home_bundle",
  "schemaVersion": 1,
  "language": "en",
  "market": "global",
  "status": "published",
  "reviewStatus": "approved",
  "sourceCorpusVersions": {
    "quran": "fixture-corpus-v1"
  },
  "payload": {
    "dailySessions": [],
    "duas": [],
    "dhikrs": [],
    "sourceItems": [],
    "quranAyahs": []
  }
}
```

Bundles are cached only after the SHA-256 matches the manifest ref and the
bundle passes client validation.

## Detail Bundles

Local push payloads may include a `bundleHint`. When content is missing locally,
`RemoteManifestClient.resolveBundleHint` can call the detail endpoint with:

- `bundle_hint`
- `language`
- `market`
- `schema_version`

The endpoint should return a bundle ref:

```json
{
  "bundleRef": {
    "bundleId": "daily_session_detail_001",
    "bundleType": "daily_session_bundle",
    "url": "https://content.example.test/bundles/daily_session_detail_001.json",
    "sha256": "...",
    "schemaVersion": 1,
    "required": false,
    "language": "en",
    "market": "global"
  }
}
```

Invalid hashes, unapproved detail bundles, missing refs, and failed downloads
fall back to the safe offline push message.

## Directus And Supabase Notes

`directus` and `supabase` are accepted provider labels for future wiring, but
the current client is provider-agnostic and speaks only the generic manifest and
bundle contracts. Do not initialize Directus, Supabase, service-role keys, or
production schemas in the app for this milestone.

## Why Seed Fallback Remains Required

The MVP must boot without remote config, without network, and without production
CMS access. Seed content remains the always-available baseline while persistent
cache provides a validated upgrade path when remote bundles are available.

## Published And Approved Filtering

Server-side publishing rules are not enough for religious-content safety. The
client still rejects any bundle that is not `published` and `approved`, and also
filters draft, in-review, rejected, or unapproved items inside otherwise valid
bundles.

## Testing Policy

Tests use `FakeContentHttpClient` only. There are no live Directus, Supabase,
FCM/APNs, OpenAI, Quran corpus, translation, or licensed-audio downloads in this
test suite.

## Security Rules

- Do not commit secrets or `.env` files.
- Do not ship a service-role key in the client.
- Do not display draft, in-review, rejected, or unapproved content.
- Do not generate Quran, Dua, Dhikr, Hadith, translations, or production source
  corpus content.
- Do not log content API tokens.
