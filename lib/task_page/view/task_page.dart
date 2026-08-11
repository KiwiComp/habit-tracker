import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/task_page/bloc/bloc.dart';
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

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: switch (state.status) {
          TaskStatus.loading => const CircularProgressIndicator(),
          TaskStatus.notFound => Text(l10n.taskPageNotFoundMessage),
          TaskStatus.loaded => Text(state.task!.name),
        },
      ),
    );
  }
}
