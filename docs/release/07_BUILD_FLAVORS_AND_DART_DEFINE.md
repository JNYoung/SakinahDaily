# Build Flavors And Dart Define

Status: Draft for release/store review.

The MVP uses Dart defines for client environment selection. No secrets are
stored in the repository.

## App Environment

Supported values:

- `SAKINAH_APP_ENV=dev`
- `SAKINAH_APP_ENV=staging`
- `SAKINAH_APP_ENV=prod`

Default: `dev`

App display names inside Flutter runtime:

- `dev`: `Sakinah Daily Dev`
- `staging`: `Sakinah Daily Staging`
- `prod`: `Sakinah Daily`

The native Android launcher label remains `Sakinah Daily`.

## Remote Content

Remote content is disabled unless explicitly configured:

```sh
--dart-define=SAKINAH_CONTENT_API_ENABLED=true
--dart-define=SAKINAH_CONTENT_API_PROVIDER=generic
--dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
--dart-define=SAKINAH_CONTENT_MANIFEST_PATH=/manifest
--dart-define=SAKINAH_CONTENT_DETAIL_BUNDLE_PATH=/detail-bundle
```

Optional:

```sh
--dart-define=SAKINAH_CONTENT_API_TOKEN=...
```

Do not commit tokens, `.env` files, `key.properties`, keystores, or service
account files. Prefer CI secrets or local untracked shell configuration.

## Telemetry

`analyticsEnabled` and `crashReportingEnabled` are hard-disabled in
`AppEnvironmentConfig` for this milestone. Do not add analytics or crash SDKs
until privacy review approves a concrete provider and data declaration.

## Example Commands

Dev:

```sh
flutter run --dart-define=SAKINAH_APP_ENV=dev
```

Staging:

```sh
flutter run \
  --dart-define=SAKINAH_APP_ENV=staging \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
```

Prod dry run without remote content:

```sh
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=prod
```
