# Piligrim

A devotional journey companion for Android, built with Flutter. It starts with
the Ayyappa deeksha and treats every observance as data.

This is the app foundation: project structure, state management, an encrypted
on-device database, the vow engine, five languages, an offline content pack,
stub journey screens and CI. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
for what is built, what is not, and where other work plugs in.

## Run it

Needs Flutter 3.50.0 (stable) and, for Android builds, JDK 17 and the Android SDK.

```sh
flutter pub get
dart run build_runner build      # generates the database code
flutter run
```

Generated files (`*.g.dart` and `lib/l10n/app_localizations*.dart`) are not
committed. `flutter pub get` regenerates the localizations; run the
`build_runner` line again after changing a table.

## Check it

```sh
dart format lib test packages
flutter analyze
flutter test
(cd packages/piligrim_design && flutter test)
```

## Build the release bundle

```sh
flutter build appbundle --release
```

Without `android/key.properties` the bundle is signed with the debug key. To
sign for Play, create an upload keystore and add:

```properties
# android/key.properties (never commit this file)
storeFile=upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

CI does the same from four repository secrets: `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.

## Languages

Telugu, Tamil, Kannada, Malayalam and English. UI strings are in
`lib/l10n/app_<code>.arb`; observance wording is in the content pack
([docs/CONTENT_PACKS.md](docs/CONTENT_PACKS.md)). All non-English text is a
draft awaiting native-speaker review.
