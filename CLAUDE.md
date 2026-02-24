# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FCryptor is a cross-platform file encryption/decryption app built with Flutter (Dart SDK ^3.6.0). It uses AES-256-CBC encryption via the `pointycastle` package and supports Android, iOS, macOS, Windows, Linux, and web.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Lint/static analysis
flutter test             # Run tests
flutter run              # Run on connected device
flutter build apk        # Android APK
flutter build macos      # macOS app
flutter build web        # Web build
```

Web deployment is automated via `deploy_web.sh` (copies `build/web/` to `docs/` for GitHub Pages).

macOS distribution uses `assets/create-dmg.sh` to create a DMG.

## Architecture

### State Management
No external state management library. The app is a single page (`HomePage`) using `StatefulWidget` with `setState()`. State is local to `_HomePageState`.

### Three-Step Wizard Flow
The UI cycles through steps defined in `lib/enums/encryption_step.dart`:
1. `selectFile` — file picker
2. `enterPassword` — password input (6–32 chars)
3. `result` — success/error display

`AnimatedSwitcher` handles transitions between steps.

### Core Services (`lib/services/`)

**`FileEncryptionService`** — All crypto logic:
- AES-256-CBC with PBKDF2 key derivation (10,000 iterations, SHA256, 8-byte random salt)
- File format: `"Salted__" + salt(8 bytes) + encrypted data`
- Encrypted files use `.fcryptor` extension (see `lib/utils/constants.dart`)
- Runs in an `Isolate` on non-web platforms to keep the UI responsive
- Key is normalized to 32 chars (padded with `'x'`)

**`FilePickerService`** — Cross-platform file I/O:
- Mobile/desktop: uses `file_picker` package
- Web: uses HTML Blob API via `universal_html`

### Error Handling Pattern
`lib/utils/result.dart` implements a `Result<S, E>` sealed class (Either pattern). Services return `Result` instead of throwing. Use `fold()`, `map()`, and `mapError()` for handling — avoid bare try-catch.

### FileModel (`lib/models/file_model.dart`)
Holds file metadata (`name`, `path`, `bytes`). Has computed properties `shortName` (truncates long names to `8...7` pattern) and `directory`.

### Platform-Specific Logic
Use `kIsWeb` and `Platform.isAndroid/isIOS/etc.` for branching. Desktop window size is fixed at 400×700 via `window_manager`.

### Monetization
`BannerAdWidget` shows Google Mobile Ads on Android/iOS only. Uses demo ad unit IDs in debug mode.

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, `MaterialApp` setup, Ads init |
| `lib/pages/home_page.dart` | Main UI, step orchestration |
| `lib/services/file_encryption_service.dart` | AES-256 encrypt/decrypt |
| `lib/services/file_picker_service.dart` | Cross-platform file pick/save |
| `lib/utils/result.dart` | `Result<S,E>` sealed class |
| `lib/utils/constants.dart` | `.fcryptor` extension, padding char |
| `lib/enums/encryption_step.dart` | Wizard step enum |

## Dependency Notes

- `pointycastle: ^4.0.0` — pure Dart crypto (AES, PBKDF2, SHA256)
- `file_picker: ^10.3.10` — file selection/saving
- `window_manager: ^0.5.1` — desktop window sizing
- `universal_html: ^2.2.4` — web Blob handling
- `google_mobile_ads: ^7.0.0` — AdMob banners
