// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aura';

  @override
  String get tagline => 'Free images, without limits';

  @override
  String get royaltyFree => 'Royalty-free';

  @override
  String get start => 'Start';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get favorites => 'Favorites';

  @override
  String get categories => 'Categories';

  @override
  String get wallpapers => 'Wallpapers';

  @override
  String get popular => 'Popular';

  @override
  String get latest => 'Latest';

  @override
  String get featured => 'Featured';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search wallpapers';

  @override
  String get searchMin => 'Type at least 2 characters';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get settings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get info => 'Details';

  @override
  String get save => 'Save';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get relatedWallpapers => 'Related Wallpapers';

  @override
  String position(int current, int total) {
    return '$current / $total';
  }

  @override
  String get guestName => 'Aura guest';

  @override
  String get guestSubtitle => 'Free image explorer';

  @override
  String get savedStat => 'Saved';

  @override
  String get downloadsStat => 'Downloads';

  @override
  String get likesStat => 'Likes';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeHint => 'A comfortable night theme';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheHint => 'Remove temporary images and searches';

  @override
  String get about => 'About';

  @override
  String get aboutBody => 'Aura shows free wallpapers from the studio.';

  @override
  String get links => 'Links';

  @override
  String get savedSection => 'Saved';

  @override
  String get emptySavedTitle => 'No saved images';

  @override
  String get emptySavedMessage => 'Save images you like and find them here.';

  @override
  String get exploreImages => 'Explore images';

  @override
  String get emptyWallpapers => 'No images';

  @override
  String get emptyHint => 'Try another word or category.';

  @override
  String get clearCacheTitle => 'Clear cache?';

  @override
  String get clearCacheBody =>
      'Temporary images and recent searches will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get replayOnboarding => 'Replay introduction';

  @override
  String get replayOnboardingHint => 'Show the introduction again';

  @override
  String get updateRequired => 'Update required';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get store => 'Store';

  @override
  String get offline =>
      'No connection. The content shown is saved and may be out of date.';

  @override
  String get refreshFailed =>
      'Could not refresh. The content shown may be out of date.';

  @override
  String get downloadSaved => 'Image saved to your gallery';

  @override
  String get downloadFailed => 'Could not download the image';

  @override
  String get galleryPermission => 'Permission is required to save images';

  @override
  String get noRelated => 'No related wallpapers yet';

  @override
  String get loadingRelated => 'Loading related wallpapers';

  @override
  String get onboard1Title => 'Discover beauty';

  @override
  String get onboard1Body =>
      'Browse free, royalty-free images arranged from nature to 3D renders.';

  @override
  String get onboard2Title => 'Save what inspires you';

  @override
  String get onboard2Body =>
      'Add images to favorites with one tap and return to them whenever you want.';

  @override
  String get onboard3Title => 'Download in high quality';

  @override
  String get onboard3Body =>
      'See the details, zoom in, then save the image to your gallery.';

  @override
  String get account => 'Account';

  @override
  String get all => 'All';

  @override
  String get searchFree => 'Search free images';

  @override
  String get searchPlaceholder => 'Search nature, neon, architecture...';

  @override
  String get clear => 'Clear';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get popularSearches => 'Most searched';

  @override
  String get popularNow => 'Trending';

  @override
  String get searching => 'Searching…';

  @override
  String resultCount(int count) {
    return '$count images';
  }

  @override
  String get noResults => 'No results';

  @override
  String get noResultsHint => 'Try a word from the title or the tags.';

  @override
  String get retry => 'Retry';

  @override
  String get open => 'Open';

  @override
  String get forYou => 'For you today';

  @override
  String get allWallpapers => 'All wallpapers';

  @override
  String get emptyPublished =>
      'Publish wallpapers from the dashboard, then pull to refresh.';

  @override
  String get notice => 'Notice';

  @override
  String get dismiss => 'Hide';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get ok => 'OK';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Image link copied';

  @override
  String copiedFor(String target) {
    return 'Link copied to paste in $target';
  }

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get instagram => 'Instagram';

  @override
  String get more => 'More';

  @override
  String get resolution => 'Resolution';

  @override
  String get fileSize => 'File size';

  @override
  String get category => 'Category';

  @override
  String get license => 'License';

  @override
  String get licenseValue => 'Free wallpaper from the app';

  @override
  String get description => 'Description';

  @override
  String get moreFromCategory => 'More from this category';

  @override
  String get linkFailed => 'Could not open the link';

  @override
  String get loadFailed => 'Could not load wallpapers';

  @override
  String get timeout => 'Connection timed out';

  @override
  String get connectionFailed => 'Could not reach the server';

  @override
  String get notFound => 'Content not found';

  @override
  String get tooManyRequests => 'Too many requests. Try again shortly.';

  @override
  String requestFailed(String code) {
    return 'Request failed ($code)';
  }

  @override
  String get invalidUrl => 'Invalid download link';

  @override
  String get emptyFile => 'The file is empty';

  @override
  String get downloadTimeout => 'Download timed out';

  @override
  String get downloadsDisabled => 'Downloads are unavailable right now';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get website => 'Website';

  @override
  String get support => 'Support';

  @override
  String get link => 'Link';

  @override
  String get homeSubtitle => 'Free, royalty-free images';
}
