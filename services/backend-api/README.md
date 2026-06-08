# Sakinah Backend API

Backend BFF foundation for Sakinah Daily MVP. It consolidates location city
lookup, timezone-aware prayer location resolution, generic content-pack
delivery, and push preview routing in one local TypeScript service.

It does not connect to production Supabase, Directus, FCM, APNs, OpenAI, or live
geocoding APIs. Local tests are deterministic and require no secrets.

## Commands

```sh
cd services/backend-api
npm install
npm test
npm run typecheck
npm run dev
```

Default port:

```text
PORT=8800
```

Content-pack directory:

```text
CONTENT_PACK_OUTPUT_DIR=.generated/content-pack
```

Generate local content packs from the existing content-agent first when testing
content delivery:

```sh
cd services/content-agent
npm run content-pack:generate

cd ../backend-api
CONTENT_PACK_OUTPUT_DIR=../content-agent/.generated/content-pack npm run dev
```

## Capabilities

### Locations

- `GET /locations/cities?query=jakarta&country=ID&locale=id`
- `GET /locations/cities/:city_id`
- `POST /locations/resolve`
- `GET /locations/timezones?country=ID`

Prayer times need city coordinates plus timezone. Timezone alone is not
prayer-ready because cities in the same timezone can have different sunrise and
sunset times.

`POST /locations/resolve` accepts:

```json
{ "cityId": "id-jakarta" }
```

or:

```json
{ "latitude": -6.2088, "longitude": 106.8456 }
```

The response includes:

- `coordinates`
- `timezone`
- `prayerCalculationMethod`
- `resolution`

### Content Delivery

Grouped BFF paths:

- `GET /content/manifest`
- `GET /content/bundles/:bundle_id.json`
- `GET /content/detail-bundle?bundle_hint=:content_id`

Existing generic client paths are also supported:

- `GET /manifest`
- `GET /bundles/:bundle_id.json`
- `GET /detail-bundle?bundle_hint=:content_id`

The service reads generated manifest/bundle files. It does not generate Quran,
Dua, Dhikr, Hadith, translations, source labels, or audio assets.

### Push Preview

- `POST /push/preview`
- `POST /push/send`
- `GET /push/messages`
- `DELETE /push/messages`

`/push/send` queues a local preview payload only. It returns `sent: false` and
does not call FCM/APNs. Lock-screen copy is checked for cycle-sensitive terms,
guaranteed outcome claims, shaming tone, fatwa-like claims, and full Quran-like
Arabic body text.

## Flutter Content API Example

The backend supports the existing generic content API defaults:

```sh
flutter run \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_PROVIDER=generic \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=http://127.0.0.1:8800
```

You can also use grouped BFF paths explicitly:

```sh
flutter run \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=http://127.0.0.1:8800 \
  --dart-define=SAKINAH_CONTENT_MANIFEST_PATH=/content/manifest \
  --dart-define=SAKINAH_CONTENT_DETAIL_BUNDLE_PATH=/content/detail-bundle
```

## Future Adapters

The local MVP project is ready for these later adapters:

- Supabase Postgres city catalog and public content views.
- Directus reviewed/published content collections.
- Supabase Storage audio asset metadata.
- FCM server-triggered daily content push jobs after token/privacy review.

Do not add production secrets, service-role keys, full Quran corpus files, or
licensed audio files to this repository.
