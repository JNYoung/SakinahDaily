# Audio Foundation

Sakinah Daily audio starts from a conservative policy layer: playback is allowed
only when the asset is approved, has a local or remote source, and does not
violate Quran recitation rules.

## Audio Policy Overview

The client models audio with `AudioAsset` metadata and evaluates it through
`AudioPolicyService` before playback. The policy returns whether audio is
playable, whether the UI should use text-only fallback, whether background
sound is allowed, and the safety flags that explain the decision.

## Quran Recitation Rules

- Quran recitation must be an approved audio asset.
- Quran recitation must never allow background music.
- Quran recitation with `bgmAllowed=true` is blocked with
  `quran_bgm_blocked`.
- Empty `url` and empty `assetPath` trigger text-only fallback.

## No Generic Quran TTS

The MVP does not use generic text-to-speech for Arabic Quran recitation because
recitation requires approved reciters, licensing, and religious review. Missing
audio is safer as text-only fallback than synthesized recitation.

## Why BGM Is Forbidden

Quran recitation is a distinct worship surface in the app. Background music
under recitation would violate the product’s religious-content safety rule and
could confuse future audio mixing behavior, so Quran assets are voice-only.

## Text-Only Fallback

If audio metadata is missing, unapproved, invalid, or has no source, the Daily
Session continues with Quran text, translation, and source-backed content. The
session must not block progress because licensed audio is not bundled in MVP.

## Approved Audio Asset Model

`AudioAsset` supports:

- `id`
- `audioType`
- `reciterName` or `voiceName`
- `url`
- `assetPath`
- `sha256`
- `durationSeconds`
- `approved`
- `bgmAllowed`
- `isQuranRecitation`
- `textOnlyFallbackRequired`

The default remains conservative: Quran recitation and no background music.

## Testing Strategy

Tests cover policy decisions, fake playback state transitions, AudioPlayerBar
play/pause behavior, Daily Session Quran safety copy, text-only fallback, local
push regression coverage, and Arabic RTL rendering. Tests do not play real
network audio and do not require licensed audio files.

## Future Work

- Licensed reciter asset ingestion.
- Offline audio cache with hash validation.
- Non-Quran reflection and dua guidance audio.
- Platform-level audio interruption handling.
- Optional ambient audio only for reviewed non-Quran surfaces.
