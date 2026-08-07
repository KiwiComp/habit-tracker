import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/add_activity/add_activity.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/bloc/bloc.dart';
import 'package:habit_tracker/start_page/models/models.dart';
import 'package:habit_tracker/start_page/widgets/widgets.dart';
import 'package:intl/intl.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // TODO(you): temporary mock data to visually verify ScheduleList.
      // Remove once a real activity data source exists (see TODO.md).
      create: (_) => StartBloc()
        // Mock data for now
        ..add(
          StartActivitiesLoaded([
            Activity(
              id: '1',
              title: 'Morning run',
              date: DateTime(2026, 8, 6, 7),
            ),
            Activity(
              id: '2',
              title: 'Read 20 pages',
              date: DateTime(2026, 8, 6, 20),
            ),
          ]),
        ),
      child: const StartView(),
    );
  }
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

  void _onDateTitleTap() {
    final today = DateTime.now();
    context.read<StartBloc>().add(StartDaySelected(today));
    unawaited(_daySelectorKey.currentState?.scrollToToday());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedDate = context.select<StartBloc, DateTime>(
      (bloc) => bloc.state.selectedDate,
    );
    final activities = context.select<StartBloc, List<Activity>>(
      (bloc) => bloc.state.activities,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.startMenuTooltip,
          // icon: Icon(Icons.menu, color: context.extendedColors.accent),
          icon: Icon(Icons.menu, color: context.colorScheme.tertiary),
          onPressed: () {},
        ),
        title: InkWell(
          onTap: _onDateTitleTap,
          borderRadius: BorderRadius.circular(context.radius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
            child: Text(DateFormat('d MMM yyyy').format(selectedDate)),
          ),
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
      ),
      body: Column(
        children: [
          SizedBox(height: context.spacing.md),
          DaySelector(key: _daySelectorKey),
          Expanded(
            child: activities.isEmpty
                ? const EmptySchedule()
                : ScheduleList(activities: activities),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.startAddActivityTooltip,
        // backgroundColor: context.extendedColors.accent,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius.lg),
        ),
        onPressed: () => AddActivitySheet.show(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const _StartNavigationBar(),
    );
  }
}

class _StartNavigationBar extends StatelessWidget {
  const _StartNavigationBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Color colorFor(Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          // ? context.extendedColors.accent
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
        onDestinationSelected: (_) {},
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
        ],
      ),
    );
  }
}
