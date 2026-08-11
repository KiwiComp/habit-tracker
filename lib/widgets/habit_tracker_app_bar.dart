import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';

/// The AppBar shared across every tab (Today/Habits/Tasks).
///
/// The leading menu button and the search/calendar-view/help actions are
/// defined once here so they're identical everywhere, and any of them wired
/// up later behaves the same app-wide. [title] is display-only — no tab has
/// a tappable title; see the "jump to today" FAB on `StartPage` for what
/// replaced that on Today.
class HabitTrackerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates a [HabitTrackerAppBar] showing [title].
  const HabitTrackerAppBar({required this.title, super.key});

  /// The title to show — the selected date on Today, the tab name on
  /// Habits/Tasks.
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppBar(
      leading: IconButton(
        tooltip: l10n.startMenuTooltip,
        icon: Icon(Icons.menu, color: context.colorScheme.tertiary),
        onPressed: () {},
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
        child: Text(title),
      ),
      actions: [
        IconButton(
          tooltip: l10n.startSearchTooltip,
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          tooltip: l10n.startCalendarViewTooltip,
          icon: const Icon(Icons.calendar_view_month_outlined),
          onPressed: () {},
        ),
        IconButton(
          tooltip: l10n.startHelpTooltip,
          icon: const Icon(Icons.help_outline),
          onPressed: () {},
        ),
      ],
    );
  }
}
