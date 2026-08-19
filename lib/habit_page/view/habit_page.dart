import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/habit_page/bloc/bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habits_repository/habits_repository.dart';

/// The full-screen detail/edit page for one habit (route `/habit/:id`).
///
/// Opened from Today or the Habits list — same page either way, see
/// `ROUTING.md`. Stub: loads and confirms the right habit opened; the
/// edit form itself is a later PR.
class HabitPage extends StatelessWidget {
  /// Creates a [HabitPage] for the habit with the given [id].
  const HabitPage({required this.id, super.key});

  /// The id of the habit to load.
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitBloc(
        id: id,
        habitsRepository: context.read<HabitsRepository>(),
      ),
      child: const _HabitView(),
    );
  }
}

class _HabitView extends StatelessWidget {
  const _HabitView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HabitBloc>().state;
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: switch (state.status) {
          HabitStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          HabitStatus.notFound => Center(
            child: Text(l10n.habitPageNotFoundMessage),
          ),
          HabitStatus.loaded => _HabitDetails(habit: state.habit!),
        },
      ),
    );
  }
}

class _HabitDetails extends StatelessWidget {
  const _HabitDetails({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xs,
        children: [Text(habit.name)],
      ),
    );
  }
}
