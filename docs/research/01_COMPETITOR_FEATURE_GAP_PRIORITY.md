# Competitor Feature Gap Priority

Status date: 2026-05-30  
Scope: Sakinah Daily MVP v0.1 product gaps after public competitor research.

This document turns competitor observations into a prioritized feature backlog.
It should guide product decisions without expanding Sakinah Daily into a full
Islamic super-app.

## 1. Positioning Guardrail

Sakinah Daily should compete as:

> A calm daily worship companion focused on prayer reminders, Quran listening,
> Dua, Dhikr, and privacy-first women's worship routines.

It should not compete by copying every utility surface from large incumbents.
The strongest product lane is: trusted content + gentle habit loop + privacy +
beautiful multilingual worship experience.

## 2. Competitor Signals

| Competitor | Public feature signals | Product implication for Sakinah |
|---|---|---|
| Muslim Pro | Prayer times, Quran, Qibla, tasbih, duas, Islamic calendar, lifestyle/content surfaces, and broad global coverage. | Users expect the basic Islamic utility stack to be reliable. Sakinah can stay narrower, but prayer/Quran/Dua basics must feel complete and trustworthy. |
| Athan / IslamicFinder | Prayer times, Athan alerts, Quran, duas, dhikr, Qibla, Ramadan and Islamic calendar utilities. | Per-prayer reminder control, location accuracy, Ramadan/fasting surfaces, and calendar polish are table stakes in utility-heavy apps. |
| Pillars | Prayer-first experience, Qibla, widgets, prayer tracking, fasting support, privacy/no-ads positioning. | A privacy-forward, clean prayer app can win by being focused. Sakinah should borrow the privacy/quality bar, not social or super-app sprawl. |
| Quranly | Quran habit tracking, reading goals, streaks, reminders, progress, and daily Quran consistency. | Daily habit scaffolding matters. Sakinah's session completion should lead into reminder, streak, and next-session loops. |
| Tarteel | Quran memorization, recitation follow-along, goals, revision planning, streaks, and AI-assisted Quran tooling. | Quran depth is a separate product category. Sakinah should not add recitation correction in MVP, but can learn from goal/progress design. |
| Quran Majeed | Full Quran, multiple translations/tafsir/audio, bookmarks, prayer times, Qibla, Islamic calendar, and broad Quran reader utility. | Sakinah's Quran entry is currently too thin for production unless scoped as session-only. A minimal approved reader slice is the safer next step. |
| Dhikr & Dua / Life With Allah | Large authenticated dua/adhkar library, categories, translations, transliteration, source/virtue context, audio, search, reminders, and counter. | Dua/Dhikr is a core differentiator. Local category/search discovery now exists, so the next risk is reviewed content depth and audio truthfulness before beta. |
| Umma / Muslim lifestyle apps | Prayer times, Quran, Qibla, Ramadan content, learning/community/lifestyle surfaces for Indonesia/MENA users. | Indonesian users expect localized vocabulary and Ramadan/lifestyle relevance, but community and UGC stay outside MVP. |

## 3. Prioritized Feature Gap List

Priority levels:

- `P0` means beta/store readiness risk.
- `P1` means strong retention or differentiation after the release baseline is
  stable.
- `P2` means later expansion.
- `X` means explicitly out of MVP or should be avoided.

| Priority | Gap | Why it matters | Current state | Proposed scope |
|---|---|---|---|---|
| P0 | Reviewed content pack and source/licensing baseline | Competitors offer deep Quran/Dua/Dhikr libraries. Sakinah cannot launch with placeholder Quran source labels or very thin seed content. | One seed session, 3 Quran ayahs, 5 duas, 5 dhikrs, placeholder Quran source labels, empty audio URLs/hashes. Local scheduled manifest/bundle generation and downfeed endpoints now exist, but beta generation blocks until reviewed inventory and metadata are complete. | Prepare a reviewed beta pack: 5-7 sessions, 30-50 duas, 20-30 dhikrs, 10-20 Quran ayah references used by sessions, source labels, reviewer status, version, reviewed date. Keep full Quran corpus out until approved. |
| P0 | Prayer location and reminder reliability | Prayer reminders are core expectation across Muslim Pro, Athan, Pillars, Quran Majeed. | v0.1 device-location baseline is implemented with explanation copy, Android foreground coarse location, manual fallback, prayer calculations, and broad notification toggle. No per-prayer control yet. | Run real-device location/notification QA before beta. Add per-prayer enablement and lead-time offset after permission QA is stable. |
| P0 | Dua/Dhikr category filtering and search | Dhikr & Dua competitors make content discoverable by moment, need, and category. Current list will feel unfinished. | Implemented for local seed content: Dua and Dhikr now have category chips, search across source-backed text fields, and safe empty states. Dhikr seed items carry category metadata. | Extend the reviewed pack into the remaining PRD categories: Before sleep, Anxiety, Travel, Study/Work, Ramadan, and Women’s Ibadah. Keep search local/privacy-safe. |
| P0 | Session completion habit loop | Quranly/Pillars-style habit loops drive retention. Sakinah's north star is weekly completed worship sessions. | Completion stores local history, save session, completed-today state, and a privacy-safe local daily reminder CTA. Notification settings now let users enable, disable, and reschedule the daily session reminder. | Add next-session suggestions after content pack breadth improves. Avoid leaderboard/gamification. |
| P0 | Audio CTA truthfulness | Competitors with audio set user expectation. Empty audio URLs and no-op buttons hurt trust. | Quran audio metadata exists but URL/hash empty; Dua detail now shows clear text-only copy instead of no-op Listen/Repeat buttons. | Before beta, ingest approved licensed audio assets with hash validation or keep unavailable audio surfaces explicitly text-only. Quran remains no BGM and no generic TTS. |
| P0 | Minimal Quran reader slice | Quran Majeed/Muslim Pro normalize full Quran access. Sakinah can stay session-led, but saved Quran routes need credible depth. | Quran entry/detail exists only for seed ayahs; no browse/search/surah list; source labels are production blockers. | Add an approved limited Quran slice for session verses plus a simple browse/search by verse reference. Defer full Quran reader until source corpus and translation rights are approved. |
| P1 | Home/widget prayer surfaces | Pillars and Athan emphasize widgets and fast prayer access. | In-app Home countdown exists; no platform widgets or lock-screen surfaces. | Add Android home-screen widget or in-app compact prayer dashboard first. iOS widgets later. Keep payload copy privacy-safe. |
| P1 | Hijri and Ramadan-light utilities | Major competitors support Islamic calendar and Ramadan. Indonesian/MENA users expect at least a respectful baseline. | Hijri date is mock/tunable; Ramadan is placeholder in content guidance. | Add Hijri date tuning, Ramadan content category, suhoor/iftar reminder design doc, and fasting-sensitive privacy review. Full Ramadan plan remains post-MVP. |
| P1 | Qibla compass polish | Prayer/Qibla is table stakes, but sensor permissions carry privacy and QA complexity. | Static bearing from selected location works; no GPS/sensor compass. | Add calibrated sensor compass only after permission/privacy review. Manual/static Qibla remains acceptable for beta if clearly positioned. |
| P1 | Content source/about transparency | Trust is central in Islamic content apps. | Implemented: Settings includes a Content Sources page explaining seed content, reviewed CMS bundles, review status meanings, and what is not generated. Quran source labels are still placeholders. | Keep the page as the baseline trust surface; later link item-level source chips when approved inventory/source metadata is broader. |
| P1 | Saved collections and continue surfaces | Competitors support bookmarks/favorites/progress. | Saved items exist for session, Dua, Dhikr, Quran verse; no folders or "continue saved" rail. | Add Home "Continue / Saved for tonight" rail and simple filters by item type. Defer folders unless content volume grows. |
| P1 | Privacy-safe analytics plan | Product metrics are defined in PRD, but no measurement exists. | Analytics service is stubbed; no SDK and no tracking. | Design consent-aware event collection or keep a local debug-only event log for beta. Do not add analytics SDK before privacy review. |
| P2 | Multi-reciter and offline audio library | Strong Quran apps offer reciters and offline downloads. | Audio foundation exists; licensed assets not present. | Add after rights, hashes, storage, and offline cache validation are finalized. |
| P2 | Rich Quran reader, tafsir, memorization plans | Quran Majeed/Tarteel own this depth. | Not in MVP. | Treat as a separate product expansion. No AI correction in MVP. |
| P2 | Account sync | Competitors often sync bookmarks/progress. | Local-only storage by design. | Add only after account, consent, deletion, and privacy policy are ready. |
| X | AI fatwa / AI religious Q&A | High religious safety risk and explicitly outside MVP. | Not implemented. | Do not build. |
| X | AI Quran recitation correction | Tarteel-like capability is out of MVP and high risk. | Not implemented. | Do not build unless a future separate product/religious review approves it. |
| X | Social/community/UGC | Large lifestyle apps may include community, but Sakinah should stay private and calm. | Not implemented. | Do not build for MVP. |
| X | Ads and aggressive paywalls | Conflicts with trust and calm positioning. | Not implemented. | Avoid in MVP. |
| X | Mosque/halal finder/lifestyle marketplace | Common in super-apps, but outside the core daily worship loop. | Not implemented. | Do not prioritize. |

## 4. Recommended Execution Order

### P0-A — Release Baseline Decision

Owner: product + engineering  
Outcome: partially decided; remaining scope decisions are content and audio.

Decided:

1. Prayer location: v0.1 requires device location with explanation copy and
   manual fallback.

Still decide:

1. Is v0.1 seed-reviewed content only, or does it require staging CMS content?
2. Are audio CTAs deferred, or does v0.1 require licensed audio assets?

Real-device Prayer location QA should happen before adding more Prayer feature
surfaces.

### P0-B — Reviewed Content Pack

Status: local scheduled generator/downfeed pipeline implemented; approved
inventory remains open.

Acceptance:

- Done: local scheduled job can package approved source records into manifest,
  bundle, and detail-bundle files.
- Done: content-agent can serve `/manifest`, `/bundles/<id>.json`, and
  `/detail-bundle` for local client delivery tests.
- Done: beta mode blocks delivery unless target counts and source/version/
  reviewed-date metadata are present.
- No production-facing Quran source placeholder remains.
- Each Quran/Dua/Dhikr/Reflection item has source, review status, version, and
  reviewed date.
- Women’s Ibadah items are reviewed for privacy-safe copy.
- Tests prove draft/in-review/unapproved content is not displayed.

### P0-C — Discoverable Dua/Dhikr

Status: local seed UX implemented on 2026-05-30; content depth remains open.

Acceptance:

- Done: Dua library supports category filters and search.
- Done: Dhikr library supports category filters and search while preserving the
  target-count counter.
- Done: search covers Arabic, transliteration, localized meaning/title, source,
  and category for local seed items.
- Done: empty states do not expose sensitive Women’s Mode status.
- Open: silent mode clarity and richer reviewed category coverage remain tied
  to the expanded content pack.

### P0-D — Reminder and Habit Loop

Status: local Set daily reminder CTA implemented on 2026-05-30; user-selectable
daily session reminder timing and Settings management implemented in the next
client continuation.

Acceptance:

- Done: Completion page includes Set daily reminder.
- Done: Reminder copy remains lock-screen safe.
- Done: Session completion keeps local-only progress and reminder preference
  semantics.
- Done: Settings exposes daily session reminder management with local enable,
  disable, and selected-time rescheduling.
- Open: Prayer reminders support at least per-prayer on/off or a documented v0.1
  deferral.
- Open: next-session suggestions are not implemented yet.

### P0-E — Audio Scope Cleanup

Status: Dua detail audio CTAs are deferred behind explicit text-only copy.

Acceptance:

- Done: No visible Dua audio button is a no-op.
- Quran audio uses approved asset metadata only.
- Quran recitation cannot enable BGM.
- If licensed assets are unavailable, text-only fallback is explicit and tested.

## 5. Product Tradeoff Notes

- Do not chase full Quran-reader parity before content rights are solved.
- Do not add community, UGC, ads, or fatwa-like AI to compete with large apps.
- Privacy/no-ads/no-tracking can be a differentiator if stated carefully and
  matched by implementation.
- Women's Mode should remain a local support mode, not a period tracker. If
  fasting or Ramadan surfaces touch cycle-sensitive topics, review privacy copy
  before implementation.
- Sakinah's advantage is the guided daily session, so every P0 item should feed
  into the daily worship loop rather than becoming isolated tools.

## 6. Source Notes

Public sources reviewed on 2026-05-30:

- Muslim Pro: https://www.muslimpro.com/
- Athan / IslamicFinder: https://www.islamicfinder.org/athan/
- Pillars: https://www.thepillarsapp.com/
- Quranly: https://www.quranly.app/
- Tarteel: https://tarteel.ai/
- Quran Majeed: https://pakdata.com/products/quran-majeed/
- Dhikr & Dua / Life With Allah: https://lifewithallah.com/dhikr-dua-app/
- Umma: https://umma.id/

These sources are used for product pattern recognition, not as specifications
to copy. Any religious content, audio, privacy, or localization feature still
requires Sakinah's existing review rules before implementation.
