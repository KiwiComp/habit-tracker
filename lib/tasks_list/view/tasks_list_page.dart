import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/tasks_list/bloc/bloc.dart';
import 'package:habit_tracker/tasks_list/widgets/widgets.dart';
import 'package:habit_tracker/widgets/widgets.dart';
import 'package:habits_repository/habits_repository.dart';

/// The Tasks tab (route `/tasks`): every one-off task, tap to open its
/// detail page.
class TasksListPage extends StatelessWidget {
  /// Creates a [TasksListPage].
  const TasksListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TasksListBloc(habitsRepository: context.read<HabitsRepository>()),
      child: const _TasksListView(),
    );
  }
}

class _TasksListView extends StatelessWidget {
  const _TasksListView();

  @override
  Widget build(BuildContext context) {
    final tasks = context.select<TasksListBloc, List<Habit>>(
      (bloc) => bloc.state.tasks,
    );
    final spacing = context.spacing;

    return Scaffold(
      appBar: HabitTrackerAppBar(title: context.l10n.startNavTasks),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: ListView.separated(
          itemCount: tasks.length,
          separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListTile(
              task: task,
              onTap: () => context.push('/task/${task.id}'),
            );
          },
        ),
      ),
    );
  }
}
