import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/task_page/bloc/bloc.dart';
import 'package:habits_repository/habits_repository.dart';

/// The full-screen detail/edit page for one task (route `/task/:id`).
///
/// Opened from Today or the Tasks list — same page either way, see
/// `ROUTING.md`. Editing the name and start date, and deleting (archiving)
/// the task, are all wired up.
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

    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus ||
          previous.archiveStatus != current.archiveStatus,
      listener: (context, state) {
        if (state.saveStatus == TaskSaveStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.editNameSaveError)));
        }
        if (state.archiveStatus == TaskArchiveStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.archiveTaskError)));
        }
        if (state.archiveStatus == TaskArchiveStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
    final bloc = context.read<TaskBloc>();

    return Material(
      child: Column(
        crossAxisAlignment: .start,
        spacing: context.spacing.xs,
        children: [
          DetailsActionTile(
            label: task.name,
            leadingIcon: Icons.edit,
            onTap: () async {
              final newName = await showEditNameDialog(
                context,
                currentName: task.name,
                label: l10n.createActivityNameLabel,
                hint: l10n.createActivityNameHintTask,
                saveButtonLabel: l10n.createActivitySaveButton,
              );
              if (newName != null) {
                bloc.add(TaskNameChangeSubmitted(newName));
              }
            },
          ),
          const _Divider(),
          DetailsActionTile(
            label: l10n.createActivityStartDateLabelTask,
            leadingIcon: Icons.today,
            date: task.startDate,
            onTap: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: task.startDate,
                firstDate: DateTime(task.startDate.year - 1),
                lastDate: DateTime(task.startDate.year + 5),
              );
              if (newDate != null) {
                bloc.add(TaskStartDateChangeSubmitted(newDate));
              }
            },
          ),
          const _Divider(),
          DetailsActionTile(
            label: l10n.deleteHabitOrTask,
            leadingIcon: Icons.delete,
            onTap: () async {
              final confirmed = await showConfirmationDialog(
                context,
                message: l10n.deleteConfirmationMessage(task.name),
                yesLabel: l10n.commonYes,
                noLabel: l10n.commonNo,
              );
              if (confirmed) {
                bloc.add(const TaskArchiveRequestSubmitted());
              }
            },
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
