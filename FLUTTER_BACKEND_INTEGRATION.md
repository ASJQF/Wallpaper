# Flutter backend integration

Base URL: `ApiConfig.baseUrl` (default `https://72.62.2.1`).

Every path below is under `/api/v1/public`. The app sends no admin JWT.

Successful list responses:

```json
{ "data": [], "meta": { "page": 1, "limit": 20, "total": 0, "totalPages": 0 } }
```

Successful object responses:

```json
{ "data": {} }
```

Errors:

```json
{ "statusCode": 404, "error": "Not Found", "message": "Wallpaper not found", "path": "/api/v1/public/wallpapers/...", "timestamp": "..." }
```

Validation errors put field messages in `details` (array). The client shows `details` when present, otherwise `message`.

## GET `/home`

No query. `data.sections[]` in admin order. Empty sections are omitted by the server.

| `type` | `items` | Screen |
| --- | --- | --- |
| `BANNERS` | `{ id, title, subtitle, imageUrl, thumbnailUrl, width, height, action }` | Home banner pager |
| `FEATURED_WALLPAPERS` | wallpaper summaries | Existing featured carousel |
| `POPULAR_WALLPAPERS` | wallpaper summaries | Horizontal card strip |
| `LATEST_WALLPAPERS` | wallpaper summaries | Horizontal card strip |
| `CATEGORY_WALLPAPERS` | wallpaper summaries, plus `category: { id, name, slug }` | Horizontal card strip |
| `CUSTOM_WALLPAPERS` | wallpaper summaries | Horizontal card strip |
| `CATEGORIES` | category objects | Cover row; tap selects that category |

Banner `action.type`: `NONE`, `OPEN_WALLPAPER` (`wallpaperId`), `OPEN_CATEGORY` (`categoryId`, `categorySlug`), `OPEN_URL` (`url`, https only).

Unknown `type` values are ignored.

Wallpaper summary fields used: `id`, `title`, `slug`, `thumbnailUrl`, `previewUrl`, `width`, `height`, `orientation`, `isFeatured`, `tags`, `categories[]` (`id`, `name`, `slug`).

## GET `/app-config`

Query: `platform` = `ANDROID` | `IOS` | `OTHER`, `appVersion` = `MAJOR.MINOR.PATCH` (`1.0.0`).

`data` fields used:

- `maintenance.enabled`, `title`, `message` — home banner
- `update.status` = `NONE` | `AVAILABLE` | `REQUIRED`, plus `update.android` or `update.ios` (`updateRequiredMessage`, `updateAvailableMessage`, `storeUrl`)
- `announcements[]`: `id`, `title`, `message`, `level` (`INFO` | `WARNING` | `PROMO`), `actionUrl`, `dismissible`
- `downloads.enabled`, `allowOriginalDownload`, `disabledMessage`
- `links.privacyPolicyUrl`, `termsOfServiceUrl`, `websiteUrl`, `supportEmail`, `other[]` (`label`, `url`) — favorites screen
- `features` — parsed, not used to show or hide screens
- `home.layout` and `serverTime` — not required; the home feed is `GET /home`

## GET `/categories`

Query: `page`, `limit` (max 100). Ordered as returned. Unpublished categories are not in this list.

Item: `id`, `name`, `slug`, `description`, `thumbnailUrl`, `previewUrl`, `wallpaperCount`.

Screen: category chips. `thumbnailUrl`, otherwise `previewUrl`, is the cover. No cover means the existing icon.

## GET `/categories/:slug`

`data` is one category object. Available on `WallpaperApi.categoryBySlug`. The UI opens a category with `categoryId` from the list or from a banner.

## GET `/wallpapers`

Query: `page`, `limit`, `sort` (`latest`, `popular`, `downloads`, `featured`, `manual`), optional `categoryId`, `categorySlug`, `orientation` (`PORTRAIT`, `LANDSCAPE`, `SQUARE`), optional `q` (2–100 chars).

Screen: category filter grid. Thumbnails only.

## GET `/wallpapers/latest`

Query: `page`, `limit`, optional `orientation`.

Screen: the infinite grid under the home sections when no category is selected.

## GET `/wallpapers/popular`

Query: `page`, `limit`, optional `orientation`.

Screen: Explore “الأكثر رواجاً” when the search box is empty.

## GET `/wallpapers/featured`

Query: `page`, `limit`, optional `orientation`.

Implemented on `WallpaperApi.featured`. The home carousel uses the `FEATURED_WALLPAPERS` section from `/home` so titles and order stay with the dashboard.

## GET `/wallpapers/search`

Query: required `q` (2–100), plus the same filters as `/wallpapers`.

Screen: Explore results, infinite scroll.

## GET `/wallpapers/:id`

`data` is the summary plus `description`, `tags`, `categories`, `downloadUrl` (string or null), `publishedAt`.

`downloadUrl` is the original when downloads and original downloads are enabled, the preview when originals are disabled, or null when downloads are off.

Screen: detail preview, info sheet, and gallery download. A 404 while refreshing a saved id removes that favorite.

## POST `/events`

Body:

```json
{
  "events": [
    {
      "wallpaperId": "uuid",
      "type": "WALLPAPER_VIEW",
      "platform": "ANDROID",
      "appVersion": "1.0.0"
    }
  ]
}
```

`type` is only `WALLPAPER_VIEW` (detail opened), `WALLPAPER_DOWNLOAD_CLICK` (download tapped), or `WALLPAPER_DOWNLOAD` (file saved). Response `202` with `data: { accepted, duplicates, rejected }`. Failures are ignored. The same view id is not sent twice in one process; the server also dedupes.

## Image URLs

| Surface | Field |
| --- | --- |
| Grid and cards | `thumbnailUrl` |
| Detail and carousel | `previewUrl` |
| Download | `downloadUrl` |
| Category chip and cover row | `thumbnailUrl`, then `previewUrl` |
| Banner | `imageUrl` (preview) |

Only `http` and `https` URLs are loaded. External actions accept `https` and `mailto`.
