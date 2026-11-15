# Content packs

Every observance is data. A pack is a folder:

```
assets/content/<pack id>/
  pack.json            template, prayers, languages, review status
  strings/en.json      base language, must be complete
  strings/te.json      translations, may be partial
```

The app reads packs through `ContentSource` (`lib/core/content/content_repository.dart`).
Today the only source is the app's own assets. A source that reads packs
downloaded from the CDN can replace it without changing any screen.

## pack.json

| Field | Meaning |
| --- | --- |
| `schemaVersion` | `1`. A build refuses a pack with a schema it does not know |
| `id`, `version` | Stored on each journey as `templateId` and `templateVersion` |
| `reviewStatus` | `draft` or `approved`. Anything but `approved` shows the draft notice on screen |
| `languages` | Language codes that have a `strings/<code>.json` |
| `template.lengthDays` | `min`, `default`, `max` |
| `template.vows[]` | `id` only. Wording is `vow.<id>.title` |
| `template.milestones[]` | `id`, `anchor` (`start` or `end`), `offsetDays`. Wording is `milestone.<id>.title` |
| `template.mascotTheme` | Which companion goes with this tradition |
| `prayers[]` | `id` only. Wording is `prayer.<id>.title` and the list `prayer.<id>.lines` |

## Rules

- The base language (`en`) must have every key the pack refers to. A pack that
  does not is rejected when it loads.
- A translation may leave keys out. Those fall back to the base language, per key.
- Never change the meaning of a vow id once journeys have used it. Add a new id.
- The bundled Ayyappa pack is a **draft**. Its vows, milestones and the three
  sample Saranam lines were written by the engineering work to exercise the
  engine. They have not been reviewed by a Guruswami or a native speaker.

`test/fixtures/content/sample_fast` is a second observance used by the tests
to prove that a different length and vow list run with no code change.
