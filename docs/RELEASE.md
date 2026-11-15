# Releasing to Google Play

Three workflows:

| Workflow | Runs | Does |
| --- | --- | --- |
| `ci.yml` | Every pull request and every push to `main` | Format check, analysis, tests, and a release build signed with the debug key. Holds no secrets |
| `release.yml` | By hand, or on a tag like `v0.1.0` | Tests, builds the bundle signed with the upload key, checks the signature, and can send it to Play internal testing as a draft |
| `launch-readiness.yml` | By hand | Lists which of the settings below are set or missing |

A release never goes further than a **draft on the internal testing track**.
Someone presses "Send for review" in Play Console, and promotion to closed
testing or production is done there by a person.

## One-time setup

Do these in order. Secrets go straight into GitHub. Never paste one into a
chat, an issue or a commit.

### 1. Create the `play-store` environment

[New environment](https://github.com/varshinicb1/piligrim/settings/environments/new),
named exactly `play-store`. Optional but sensible: add yourself as a required
reviewer, so that every release waits for your approval.

### 2. Create the upload key

On your own computer (needs a JDK):

```sh
keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep `upload-keystore.jks` and its passwords somewhere safe and backed up,
outside any repository. Then, in the `play-store` environment, add:

| Kind | Name | Value |
| --- | --- | --- |
| Secret | `ANDROID_KEYSTORE_BASE64` | Output of `base64 -w0 upload-keystore.jks` (macOS: `base64 -i upload-keystore.jks`) |
| Secret | `ANDROID_KEYSTORE_PASSWORD` | The keystore password you chose |
| Secret | `ANDROID_KEY_ALIAS` | `upload` |
| Secret | `ANDROID_KEY_PASSWORD` | The key password you chose |
| Variable | `UPLOAD_KEY_SHA1` | The `SHA1:` line from `keytool -list -v -keystore upload-keystore.jks -alias upload` |

After this, `release.yml` with "none (build and verify only)" produces a
signed bundle as a downloadable artifact. Nothing below is needed for that.

### 3. Create the app in Play Console

This needs a Google Play developer account, which has a one-time fee, and the
plan recommends registering it as an organization.

Before the first upload, be sure about the package name
`com.vidyuthlabs.piligrim`. **It can never be changed once a bundle is
uploaded.** To change it, edit `applicationId` and `namespace` in
`android/app/build.gradle.kts`, the Kotlin package of `MainActivity`, and
`PACKAGE_NAME` in `release.yml`.

Create the app in Play Console, then upload the **first** bundle by hand:
download the artifact from a `release.yml` run and add it to a new internal
testing release. Google requires the first upload of a new app to be manual.
Enrol in Play App Signing when asked.

### 4. Create the Play service account

1. In a Google Cloud project that allows service account keys, enable the
   [Google Play Android Developer API](https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com).
   It takes about five minutes to take effect.
2. In the same project, create a service account and a JSON key for it.
   Creating these is free.
3. In Play Console, Users and permissions, invite the service account's email
   address. Under App permissions choose this app and grant "Release apps to
   testing tracks".
4. Add the whole JSON file as the secret `PLAY_SERVICE_ACCOUNT_JSON` in the
   `play-store` environment, then delete the file from your computer.

## Making a release

1. Merge to `main` with CI green.
2. Either run [Release](https://github.com/varshinicb1/piligrim/actions/workflows/release.yml)
   by hand and choose `internal`, or push a tag:
   `git tag v0.1.0 && git push origin v0.1.0`.
3. The version name is the tag (or `version:` in `pubspec.yaml` for a manual
   run). The version code is 1000 plus the workflow's run number, so it
   always rises.
4. Open Play Console, review the draft, and send it.

## When something fails

| Symptom | Cause |
| --- | --- |
| "A release needs these secrets" | Step 2 is not done, or the secrets are on the repository instead of the `play-store` environment |
| "signed with ..., not the upload key" | `UPLOAD_KEY_SHA1` does not match the keystore in `ANDROID_KEYSTORE_BASE64` |
| "API has not been used in project" | The Android Developer API is not enabled in the service account's project |
| "The caller does not have permission" | The service account has not been invited in Play Console, or lacks the testing-tracks permission |
| "Package not found" | The app does not exist in Play Console yet, or the first manual upload has not been done |
| "Version code has already been used" | Re-run the workflow instead of re-running a failed job, so the run number rises |
