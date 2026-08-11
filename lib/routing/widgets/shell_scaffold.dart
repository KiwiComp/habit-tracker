import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// The shell scaffold behind `StatefulShellRoute.indexedStack`.
///
/// Owns the bottom nav bar shared across the Today/Habits/Tasks tabs — see
/// `ROUTING.md`. Switching tabs goes through `navigationShell.goBranch`,
/// never `context.go`, so each branch's stack and state survive the switch.
class ShellScaffold extends StatelessWidget {
  /// Creates a [ShellScaffold] wrapping [navigationShell].
  const ShellScaffold({required this.navigationShell, super.key});

  /// The shell's navigation state, supplied by `StatefulShellRoute`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
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
