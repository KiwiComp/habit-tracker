import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/routing/models/models.dart';
import 'package:habit_tracker/start_page/bloc/bloc.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

/// The shell scaffold behind `StatefulShellRoute.indexedStack`.
///
/// Owns the chrome shared across the Today/Habits/Tasks tabs — see
/// `ROUTING.md` and `KNOWN_GAPS.md`'s "AppBar + jump to today FAB" entry: the
/// bottom nav bar, and the add-activity FAB (available from any tab, not
/// just Today). Switching tabs goes through `navigationShell.goBranch`,
/// never `context.go`, so each branch's stack and state survive the switch.
///
/// Also provides `StartBloc` — moved up from `StartPage` so the FAB can read
/// its `selectedDate` on the Today tab (see `_ShellScaffoldView`). This
/// doesn't change the bloc's lifetime: `IndexedStack` already keeps every
/// branch's widgets (and therefore the old page-local `BlocProvider`) alive
/// for as long as the shell is, so it's created once either way.
class ShellScaffold extends StatelessWidget {
  /// Creates a [ShellScaffold] wrapping [navigationShell].
  const ShellScaffold({required this.navigationShell, super.key});

  /// The shell's navigation state, supplied by `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StartBloc(habitsRepository: context.read<HabitsRepository>()),
      child: _ShellScaffoldView(navigationShell: navigationShell),
    );
  }
}

class _ShellScaffoldView extends StatelessWidget {
  const _ShellScaffoldView({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Only on the Today branch does the FAB seed the new activity's start
  // date from the currently selected day rather than today.
  ShellBranch get _currentBranch =>
      ShellBranch.values[navigationShell.currentIndex];

  bool get _isOnTodayTab => _currentBranch == ShellBranch.today;

  Future<void> _onAddActivityTap(BuildContext context) async {
    final type = await AddActivitySheet.show(context);
    if (type == null || !context.mounted) return;
    final startDate = _isOnTodayTab
        ? context.read<StartBloc>().state.selectedDate
        : null;
    await context.push(
      '/create',
      extra: CreateActivityRouteArgs(type: type, startDate: startDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        heroTag: 'shellAddActivityFab',
        tooltip: context.l10n.startAddActivityTooltip,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius.lg),
        ),
        onPressed: () => _onAddActivityTap(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _ShellNavigationBar(
        navigationShell: navigationShell,
      ),
    );
  }
}

class _ShellNavigationBar extends StatelessWidget {
  const _ShellNavigationBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Color colorFor(Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          ? context.colorScheme.tertiary
          : context.colorScheme.onSurfaceVariant;
    }

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: colorFor(states)),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) =>
              AppTextStyle.labelMedium.copyWith(color: colorFor(states)),
        ),
      ),
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.event_available_outlined),
            label: l10n.startNavToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.military_tech_outlined),
            label: l10n.startNavHabits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            label: l10n.startNavTasks,
          ),
        ],
      ),
    );
  }
}
