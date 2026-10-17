# أورا

Flutter client for the Wallpaper CMS. It reads the public NestJS API only. There is no user account.

## API

The default origin is `https://72.62.2.1`. Override it at build time:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://72.62.2.1
flutter build appbundle --release --dart-define=API_BASE_URL=https://72.62.2.1
```

Local backend example:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

`API_BASE_URL` must not have a trailing slash. The app appends `/api/v1/public`. Keep `version` in `pubspec.yaml` aligned with `ApiConfig.appVersion` (`1.0.0`). The remote update check sends that value as `appVersion`.

## What the app loads

- Home sections from `GET /api/v1/public/home` (order, titles, banners, featured, latest, popular, category rows). Unknown section types are skipped.
- Published categories and cover images from `GET /api/v1/public/categories`.
- Wallpaper pages from `/wallpapers`, `/wallpapers/latest`, `/wallpapers/popular`, and `/wallpapers/search`.
- Detail and the permitted download URL from `GET /api/v1/public/wallpapers/:id`.
- Maintenance, update messages, announcements, download availability, and https links from `GET /api/v1/public/app-config`.
- Anonymous `WALLPAPER_VIEW`, `WALLPAPER_DOWNLOAD_CLICK`, and `WALLPAPER_DOWNLOAD` events.

Grids use thumbnail URLs. The detail screen uses the preview URL. Downloads use `downloadUrl` only, which the server sets to the original, the preview, or `null`.

Favorites, likes, and recent searches stay on the device. A favorite whose wallpaper is no longer published is removed after the next successful refresh.

## Checks

```bash
flutter pub get
flutter analyze
flutter test
```

Release signing in `android/app/build.gradle.kts` is still the debug keystore. Do not replace it until a release keystore is approved.

See `FLUTTER_BACKEND_INTEGRATION.md` for each endpoint and `FLUTTER_API_INTEGRATION_PROGRESS.md` for the audit.
