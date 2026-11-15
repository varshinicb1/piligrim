# Architecture

One Flutter app, offline-first. The phone's own encrypted database is the
source of truth, and nothing in this foundation talks to a network.

Sources: the architecture and team plan, the v1 product spec (story ids below),
the UX spec, and the motion and state-machine spec.

## Layout

```
lib/
  main.dart
  app/                 app widget, router, providers, companion sync
  core/
    vow_engine/        pure Dart: dates, templates, day numbers, summaries
    content/           content packs and where they load from
    db/                Drift tables, encrypted executor, repositories
    sync/              outbox interface (off until the backend exists)
    companion/         mascot contract, still-pose controller, view
    l10n/              the five launch languages
    widgets/           small shared widgets
  features/            one folder per screen group
  l10n/                ARB files, one per language
packages/
  piligrim_design/     design tokens and theme, owned by the design work
assets/
  content/             bundled content packs
  companion/           still poses and the input contract
```

Rules of thumb: `core/vow_engine` imports nothing from Flutter or the
database. Screens read state from Riverpod providers in `app/providers.dart`
and write through repositories. Screens take spacing, colour and type from
`piligrim_design` and never hard-code them.

## What is built, against the product spec

| Story | State |
| --- | --- |
| ONB-1 Choose my language | Built: five languages in their own script, applies at once, changeable in settings, per-key fallback to English |
| ONB-6 Try it before signing in | This is the only mode so far: no account, data on the phone only |
| JRN-1 Start my deeksha | Built: start date (past, today or future), length within the template's range, one active journey, works offline. Backfill of earlier days is not built |
| JRN-2 Record my sankalpam | Text only, at setup |
| JRN-3 See today at a glance | Day number, countdown before the start, milestone of the day. No Guruswami message or next-milestone date yet |
| JRN-5 Add a deeksha without new code | Built and tested with a second sample pack. Invalid packs are rejected. "Last good pack stays in use" waits for downloaded packs |
| CHK-1 Tick my vows | Built: each tick saves at once, partial days allowed, no comment on which |
| CHK-3 Write a line | Built: 500 characters |
| CHK-2, CHK-4 Photo and voice note | Buttons are present and disabled |
| MASC-1, MASC-2 Companion | Contract wired with still poses: greet, comfort after missed days, day-complete celebration. No Rive file yet |
| PLAT-1 Offline | Everything built so far works with no network. The app does not request the internet permission |
| PLAT-3 Older eyes | Follows the phone's text size; 56 high buttons. Not yet checked at 200% |
| Privacy | Database encrypted at rest, key in the Android Keystore, Android backup off, "Delete my data" in settings |

Not started: sign-in, age gate and consent (ONB-2 to ONB-5), groups,
reminders (CHK-5), Journey Book content, Ask, payments.

## Seams for the other work

| Work | Where it plugs in | Contract |
| --- | --- | --- |
| Design system | `packages/piligrim_design` | Edit tokens and theme there. Screens pick the changes up. Fonts are not bundled yet (see below) |
| Character and motion | `lib/core/companion/` | `CompanionController` is the published contract. Replace `StillCompanionController` and the body of `CompanionView` with the Rive runtime. `assets/companion/companion-contract.json` is tested against the Dart input names |
| Content and localization | `assets/content/`, `lib/l10n/*.arb` | `docs/CONTENT_PACKS.md`. UI strings are ARB files with ICU plurals |
| Backend and sync | `lib/core/sync/outbox.dart` | Repositories record every change to an `Outbox` in the same transaction. Swap `DisabledOutbox` for `DatabaseOutbox` and add an uploader |
| Journey features | `lib/features/` | Read `journeyOverviewProvider`; write through `JourneyRepository` |
| AI and on-device ML | `DayEntries.transcript`, `voiceNotePath` | Columns exist; nothing writes them yet |

## Data

Drift over SQLite3 Multiple Ciphers (`hooks.user_defines.sqlite3.source: sqlite3mc`
in `pubspec.yaml`). The plan named SQLCipher through `sqlcipher_flutter_libs`;
that package is now end-of-life, and this is the route the `sqlite3` package
documents in its place. `applyEncryptionKey` refuses to open a database if the
bundled SQLite has no encryption support.

Tables: `journeys`, `day_entries` (one per calendar day), `vow_checks` (one
row per vow per day, for last-writer-wins per field), `milestone_records`,
`outbox_items`, `app_settings`. Ids are UUIDs so rows can sync later. Dates
are stored as `YYYY-MM-DD` in the devotee's own calendar.

Schema version is 1. Before the first release that reaches real devotees, add
Drift schema snapshots and migration tests.

## Decisions taken here that the owner may want to change

- **Application id** `com.vidyuthlabs.piligrim`. It cannot change after the
  first Play upload, and it carries the unconfirmed "Piligrim" spelling.
- **Minimum Android** 8.0 (API 26), from the product spec.
- **Tabs** Today, Journey, Group, Guide, from the UX spec, which lists four
  tabs versus five as an open question.
- **Fonts**: the design package names Anek and Noto Sans families that are not
  bundled. Until they are, Android falls back to its system fonts. Their size
  against the 40 MB budget has not been measured.
- **iOS**: the `ios/` folder is generated and has never been built. CI does
  not build it, because macOS runners use paid minutes at ten times the rate.

## Known gaps in this foundation

- The translations in the ARB files and the content pack are drafts written
  without a native speaker.
- "First open today" is not tracked, so the companion greets on every launch.
- Reduce-motion is not passed to the companion yet.
- No golden or screenshot tests, and no run on a real or emulated phone.
