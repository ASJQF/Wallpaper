# Flutter API integration progress

## Current architecture

The app is a single Flutter package (`provider`, no user login). Navigation is a bottom bar: Home, Explore, Favorites. Detail is a pushed route. Visual language (dark theme, Arabic RTL, cards, carousel, glass action bar) is unchanged.

| Area | Implementation |
| --- | --- |
| Config | `ApiConfig.baseUrl` from `String.fromEnvironment('API_BASE_URL', defaultValue: 'https://72.62.2.1')` |
| HTTP | Existing `package:http` client, 10s connect timeout, 15s headers, 20s body, one retry for GET 502/503/504 and timeouts |
| State | `AppController` |
| Images | `NetworkArt` (`Image.network`) with decode width caps; memory cache limited to 80 images / 80 MB |
| Favorites | Device storage via `shared_preferences` (wallpaper ids plus a small JSON copy of each card) |
| Downloads | Bytes from `downloadUrl`, saved with `gal` into the photo library. Extension comes from the URL. |
| Offline | Last successful catalog snapshot. A banner says the copy may be stale. Resume refreshes if the last success is older than 2 minutes or the last load failed. |

There is no bundled wallpaper catalog. The previous debug-only `localhost` / `10.0.2.2` fallback was removed so release builds use the production host unless `--dart-define` overrides it.

## Backend contracts used

Verified against `wallpaper-backend` public controller, DTOs, home assembler, config service, banner DTO, and events DTO. Successful JSON is `{ data }` or `{ data, meta }`. Errors are `{ statusCode, message, details? }` and are not wrapped.

Home section types: `BANNERS`, `FEATURED_WALLPAPERS`, `POPULAR_WALLPAPERS`, `LATEST_WALLPAPERS`, `CATEGORY_WALLPAPERS`, `CUSTOM_WALLPAPERS`, `CATEGORIES`. Any other type is ignored. Sections with no usable items are skipped.

Event types sent: `WALLPAPER_VIEW`, `WALLPAPER_DOWNLOAD_CLICK`, `WALLPAPER_DOWNLOAD`. Non-UUID ids are not sent.

## Screens

- Home: maintenance, update, announcements, category chips (cover image when the API sends one), dynamic sections, then a paginated latest or category grid with pull-to-refresh and infinite scroll.
- Explore: tag and recent search, popular grid, debounced search with pagination.
- Favorites: local bookmarks, download count, theme, cache clear, remote https/mailto links.
- Detail: preview image, favorite, share (copies the download or preview URL), info, gallery download with progress.

## Not applied in the UI

- `features` on app-config is parsed and kept as booleans. The map is open-ended and the current screens have no extra flag-gated controls. Downloads follow `downloads.enabled`. `allowOriginalDownload` is enforced by the server when it builds `downloadUrl`.
- There is no set-as-wallpaper API in this project. Android saves into the gallery; iOS cannot set the wallpaper programmatically, so the same gallery save is used. Automatic wallpaper changes are not claimed.
- Public wallpaper payloads do not include file size or like counts. The card shows `—` for size and a device-only like toggle.
- Release signing is still the debug keystore. It was not changed.

## Validation

Executed on this machine:

- `flutter pub get` — succeeded
- `flutter analyze` — no issues
- `flutter test` — 9 tests passed (`catalog_contract_test.dart`, `widget_test.dart`)

`flutter build apk` / `appbundle` were not run in this session. The Android manifest already has `INTERNET`, and release networking does not disable certificate checks.

## Blockers

None in the client. The app cannot show wallpapers until the VPS is serving `https://72.62.2.1/api/v1/public/home` with a certificate valid for that IP. TLS verification is left at the platform default.
