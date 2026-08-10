import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habits_repository/habits_repository.dart';

class App extends StatelessWidget {
  /// Creates an [App]. The `habitsRepository` argument lets tests supply a
  /// fake in place of the real one — constructing a real [HabitsRepository]
  /// opens a file-backed Drift connection that schedules a `Timer`, which
  /// trips `flutter_test`'s fake-async widget tests if left to the default.
  const App({super.key, this._habitsRepository});

  final HabitsRepository? _habitsRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => _habitsRepository ?? HabitsRepository(),
      dispose: (repository) => repository.close(),
      child: MaterialApp(
        theme: const AppTheme.light().themeData,
        darkTheme: const AppTheme.dark().themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StartPage(),
      ),
    );
  }
}
