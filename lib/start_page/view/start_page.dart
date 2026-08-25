import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/bloc/bloc.dart';
import 'package:habit_tracker/start_page/utils/date_time_x.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:habit_tracker/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';
import 'package:intl/intl.dart';

// `StartBloc` is provided by `ShellScaffold`, an ancestor of every branch —
// not here — so the add-activity FAB (also in the shell) can read
// `selectedDate` regardless of which tab it's tapped from. See
// `ShellScaffold`'s doc comment.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) => const StartView();
}

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  // A GlobalKey (ephemeral UI wiring, not app state) so the app bar's
  // "jump to today" tap can imperatively command DaySelector's scroll
  // position. Held on State so it's created once and stays stable across
  // rebuilds, rather than recreated every time build() runs.
  final GlobalKey<DaySelectorState> _daySelectorKey =
      GlobalKey<DaySelectorState>();

  void _onJumpToTodayTap() {
    final today = DateTime.now();
    context.read<StartBloc>().add(StartDaySelected(today));
    unawaited(_daySelectorKey.currentState?.scrollToToday());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<StartBloc>();
    final selectedDate = context.select<StartBloc, DateTime>(
      (bloc) => bloc.state.selectedDate,
    );
    final activities = context.select<StartBloc, List<Habit>>(
      (bloc) => bloc.state.activities,
    );
    final completeHabitIds = context.select<StartBloc, Set<String>>(
      (bloc) => bloc.state.completedHabitIds,
    );
    final isToday = selectedDate.isSameDayAs(DateTime.now());
    final isAfterToday = selectedDate.isAfter(DateTime.now());

    return Scaffold(
      appBar: HabitTrackerAppBar(
        title: isToday
            ? l10n.startNavToday
            : DateFormat(
                'd MMM yyyy',
                context.locale.toString(),
              ).format(selectedDate),
      ),
      body: Column(
        children: [
          SizedBox(height: context.spacing.md),
          DaySelector(key: _daySelectorKey),
          Expanded(
            child: activities.isEmpty
                ? const EmptySchedule()
                : ScheduleList(
                    activities: activities,
                    completedHabitIds: completeHabitIds,
                    onActivityTap: isAfterToday
                        ? null
                        : (habit) => bloc.add(
                            ToggleActivityMarking(habit.id, selectedDate),
                          ),
                    onOpenActivity: (habit) => context.push(
                      habit.isTask ? '/task/${habit.id}' : '/habit/${habit.id}',
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: isToday
          ? null
          : FloatingActionButton(
              heroTag: 'startPageJumpToTodayFab',
              tooltip: l10n.startJumpToTodayTooltip,
              backgroundColor: context.colorScheme.tertiary,
              foregroundColor: context.colorScheme.onTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.radius.lg),
              ),
              onPressed: _onJumpToTodayTap,
              child: const Icon(Icons.today),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
