import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aura'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Free images, without limits'**
  String get tagline;

  /// No description provided for @royaltyFree.
  ///
  /// In en, this message translates to:
  /// **'Royalty-free'**
  String get royaltyFree;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @wallpapers.
  ///
  /// In en, this message translates to:
  /// **'Wallpapers'**
  String get wallpapers;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search wallpapers'**
  String get searchHint;

  /// No description provided for @searchMin.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get searchMin;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get info;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @relatedWallpapers.
  ///
  /// In en, this message translates to:
  /// **'Related Wallpapers'**
  String get relatedWallpapers;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String position(int current, int total);

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Aura guest'**
  String get guestName;

  /// No description provided for @guestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free image explorer'**
  String get guestSubtitle;

  /// No description provided for @savedStat.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedStat;

  /// No description provided for @downloadsStat.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsStat;

  /// No description provided for @likesStat.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likesStat;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeHint.
  ///
  /// In en, this message translates to:
  /// **'A comfortable night theme'**
  String get darkModeHint;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheHint.
  ///
  /// In en, this message translates to:
  /// **'Remove temporary images and searches'**
  String get clearCacheHint;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Aura shows free wallpapers from the studio.'**
  String get aboutBody;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @savedSection.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedSection;

  /// No description provided for @emptySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved images'**
  String get emptySavedTitle;

  /// No description provided for @emptySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Save images you like and find them here.'**
  String get emptySavedMessage;

  /// No description provided for @exploreImages.
  ///
  /// In en, this message translates to:
  /// **'Explore images'**
  String get exploreImages;

  /// No description provided for @emptyWallpapers.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get emptyWallpapers;

  /// No description provided for @emptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try another word or category.'**
  String get emptyHint;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache?'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Temporary images and recent searches will be removed.'**
  String get clearCacheBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @replayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Replay introduction'**
  String get replayOnboarding;

  /// No description provided for @replayOnboardingHint.
  ///
  /// In en, this message translates to:
  /// **'Show the introduction again'**
  String get replayOnboardingHint;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'No connection. The content shown is saved and may be out of date.'**
  String get offline;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh. The content shown may be out of date.'**
  String get refreshFailed;

  /// No description provided for @downloadSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved to your gallery'**
  String get downloadSaved;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download the image'**
  String get downloadFailed;

  /// No description provided for @galleryPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission is required to save images'**
  String get galleryPermission;

  /// No description provided for @noRelated.
  ///
  /// In en, this message translates to:
  /// **'No related wallpapers yet'**
  String get noRelated;

  /// No description provided for @loadingRelated.
  ///
  /// In en, this message translates to:
  /// **'Loading related wallpapers'**
  String get loadingRelated;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover beauty'**
  String get onboard1Title;

  /// No description provided for @onboard1Body.
  ///
  /// In en, this message translates to:
  /// **'Browse free, royalty-free images arranged from nature to 3D renders.'**
  String get onboard1Body;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Save what inspires you'**
  String get onboard2Title;

  /// No description provided for @onboard2Body.
  ///
  /// In en, this message translates to:
  /// **'Add images to favorites with one tap and return to them whenever you want.'**
  String get onboard2Body;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'Download in high quality'**
  String get onboard3Title;

  /// No description provided for @onboard3Body.
  ///
  /// In en, this message translates to:
  /// **'See the details, zoom in, then save the image to your gallery.'**
  String get onboard3Body;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchFree.
  ///
  /// In en, this message translates to:
  /// **'Search free images'**
  String get searchFree;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search nature, neon, architecture...'**
  String get searchPlaceholder;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Most searched'**
  String get popularSearches;

  /// No description provided for @popularNow.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get popularNow;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String resultCount(int count);

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a word from the title or the tags.'**
  String get noResultsHint;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you today'**
  String get forYou;

  /// No description provided for @allWallpapers.
  ///
  /// In en, this message translates to:
  /// **'All wallpapers'**
  String get allWallpapers;

  /// No description provided for @emptyPublished.
  ///
  /// In en, this message translates to:
  /// **'Publish wallpapers from the dashboard, then pull to refresh.'**
  String get emptyPublished;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get dismiss;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Image link copied'**
  String get linkCopied;

  /// No description provided for @copiedFor.
  ///
  /// In en, this message translates to:
  /// **'Link copied to paste in {target}'**
  String copiedFor(String target);

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSize;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @licenseValue.
  ///
  /// In en, this message translates to:
  /// **'Free wallpaper from the app'**
  String get licenseValue;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @moreFromCategory.
  ///
  /// In en, this message translates to:
  /// **'More from this category'**
  String get moreFromCategory;

  /// No description provided for @linkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get linkFailed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load wallpapers'**
  String get loadFailed;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get timeout;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server'**
  String get connectionFailed;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found'**
  String get notFound;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again shortly.'**
  String get tooManyRequests;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed ({code})'**
  String requestFailed(String code);

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid download link'**
  String get invalidUrl;

  /// No description provided for @emptyFile.
  ///
  /// In en, this message translates to:
  /// **'The file is empty'**
  String get emptyFile;

  /// No description provided for @downloadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Download timed out'**
  String get downloadTimeout;

  /// No description provided for @downloadsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Downloads are unavailable right now'**
  String get downloadsDisabled;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free, royalty-free images'**
  String get homeSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
