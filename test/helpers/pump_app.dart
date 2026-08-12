import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habits_repository/habits_repository.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed, localized [MaterialApp].
  ///
  /// App widgets read design tokens off [AppTheme] (via `AppContextExtension`
  /// and the registered `AppExtendedColors` extension) and their strings off
  /// the app localizations, so both must be in the tree. Pass
  /// [habitsRepository] to make a `RepositoryProvider<HabitsRepository>`
  /// available above the widget (e.g. for pages that build a bloc from it),
  /// and [navigatorObserver] to spy on navigation.
  ///
  /// The caller supplies its own `Scaffold` when the widget-under-test needs a
  /// `Material` ancestor; full pages that already return a `Scaffold` can be
  /// passed directly.
  Future<void> pumpApp(
    Widget widget, {
    HabitsRepository? habitsRepository,
    NavigatorObserver? navigatorObserver,
  }) {
    final app = MaterialApp(
      theme: const AppTheme.light().themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [?navigatorObserver],
      home: widget,
    );

    return pumpWidget(
      habitsRepository == null
          ? app
          : RepositoryProvider.value(value: habitsRepository, child: app),
    );
  }
}
