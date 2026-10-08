import 'package:flutter/widgets.dart';

import '../data/wallpaper_repository.dart';
import '../models/folder.dart';
import '../models/wallpaper.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final WallpaperRepository repository;

  final Set<String> favoriteIds = {};

  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(Wallpaper wallpaper) {
    if (!favoriteIds.remove(wallpaper.id)) {
      favoriteIds.add(wallpaper.id);
    }
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

extension AppStateContext on BuildContext {
  AppState get app => AppScope.of(this);
}
