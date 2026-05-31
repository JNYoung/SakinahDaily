# Content Source Transparency

Date: 2026-05-31

## Status

Implemented in the Flutter client at `/settings/content-sources`.

## Product Purpose

Sakinah Daily needs a visible trust surface for religious content. The page
explains where content can come from, what review states mean, and what the app
does not generate.

## Client Behavior

- Settings includes a Content Sources entry.
- The Content Sources page is localized in English, Indonesian, and Arabic.
- The page explains the bundled seed content used for MVP offline flows.
- The page explains that future CMS bundles must be published and approved
  before display.
- The page explains that draft, in-review, rejected, and revoked content is
  hidden from the client.
- The page states that Sakinah does not generate Quran, dua, dhikr, Hadith,
  translations, or source labels.
- The page does not display remote content API tokens or other secrets.

## Non-Goals

- No new Quran, dua, dhikr, Hadith, translation, or source text is added.
- No live CMS, Supabase, Directus, OpenAI, FCM/APNs, or corpus download is
  introduced.
- No legal claim is finalized by this page; store/legal copy still needs review.

## Remaining Work

- Replace placeholder Quran seed source labels with approved source-corpus
  labels before production.
- Add reviewed content inventory so beta content-pack generation can deliver the
  target session, dua, dhikr, and Quran slice counts.
- Consider linking item-level source chips to this page after content volume and
  source metadata are broader.
