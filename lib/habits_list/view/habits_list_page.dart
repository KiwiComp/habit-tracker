import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/habits_list/bloc/bloc.dart';
import 'package:habit_tracker/habits_list/widgets/widgets.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

/// The Habits tab (route `/habits`): every recurring habit, tap to open its
/// detail page.
class HabitsListPage extends StatelessWidget {
  /// Creates a [HabitsListPage].
  const HabitsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HabitsListBloc(habitsRepository: context.read<HabitsRepository>()),
      child: const _HabitsListView(),
    );
  }
}

class _HabitsListView extends StatelessWidget {
  const _HabitsListView();

  @override
  Widget build(BuildContext context) {
    final habits = context.select<HabitsListBloc, List<Habit>>(
      (bloc) => bloc.state.habits,
    );
    final spacing = context.spacing;

    return Scaffold(
      appBar: HabitTrackerAppBar(title: context.l10n.startNavHabits),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: habits.isEmpty
            ? TaskAndHabitListEmptyView(
                title: context.l10n.habitsListEmptyTitle,
                text: context.l10n.habitsListEmptySubtitle,
              )
            : ListView.separated(
                separatorBuilder: (_, _) => SizedBox(height: spacing.sm),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return HabitListTile(
                    habit: habit,
                    onTap: () => context.push('/habit/${habit.id}'),
                  );
                },
              ),
      ),
    );
  }
}
