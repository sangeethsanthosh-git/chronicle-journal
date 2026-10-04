import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeViewMode {
  study, // The Living Journal illustrated interactive 2D study world
  overview, // Classic journal overview and cards
}

class HomeViewModeNotifier extends Notifier<HomeViewMode> {
  @override
  HomeViewMode build() => HomeViewMode.study;

  void setMode(HomeViewMode mode) => state = mode;
}

final homeViewModeProvider =
    NotifierProvider<HomeViewModeNotifier, HomeViewMode>(() {
      return HomeViewModeNotifier();
    });
