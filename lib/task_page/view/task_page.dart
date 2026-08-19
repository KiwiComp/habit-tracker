import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/task_page/bloc/bloc.dart';
import 'package:habit_tracker/task_page/widgets/task_details_tile.dart';
import 'package:habits_repository/habits_repository.dart';

/// The full-screen detail/edit page for one task (route `/task/:id`).
///
/// Opened from Today or the Tasks list — same page either way, see
/// `ROUTING.md`. Stub: loads and confirms the right task opened; the edit
/// form itself is a later PR.
class TaskPage extends StatelessWidget {
  /// Creates a [TaskPage] for the task with the given [id].
  const TaskPage({required this.id, super.key});

  /// The id of the task to load.
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TaskBloc(id: id, habitsRepository: context.read<HabitsRepository>()),
      child: const _TaskView(),
    );
  }
}

class _TaskView extends StatelessWidget {
  const _TaskView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskBloc>().state;
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: switch (state.status) {
          TaskStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          TaskStatus.notFound => Center(
            child: Text(l10n.taskPageNotFoundMessage),
          ),
          TaskStatus.loaded => _TaskDetails(task: state.task!),
        },
      ),
    );
  }
}

class _TaskDetails extends StatelessWidget {
  const _TaskDetails({required this.task});

  final Habit task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      child: Column(
        crossAxisAlignment: .start,
        spacing: context.spacing.xs,
        children: [
          TaskDetailsTile(
            label: task.name,
            icon: Icons.edit,
            onTap: () {},
          ),
          const _Divider(),
          TaskDetailsTile(
            label: l10n.createActivityStartDateLabelTask,
            icon: Icons.today,
            date: task.startDate,
            onTap: () {},
          ),
          const _Divider(),
          TaskDetailsTile(
            label: l10n.deleteHabitOrTask,
            icon: Icons.delete,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      indent: 0,
      endIndent: 0,
      height: 1,
    );
  }
}
