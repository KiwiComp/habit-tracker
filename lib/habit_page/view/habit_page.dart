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

    return BlocListener<HabitBloc, HabitState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus ||
          previous.archiveStatus != current.archiveStatus,
      listener: (context, state) {
        if (state.saveStatus == HabitSaveStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.editNameSaveError)));
        }
        if (state.archiveStatus == HabitArchiveStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.archiveTaskError)));
        }
        if (state.archiveStatus == HabitArchiveStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
    final bloc = context.read<HabitBloc>();
    final l10n = context.l10n;
    final lastDate = habit.endDate ?? DateTime(habit.startDate.year + 5);

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xs,
        children: [
          DetailsActionTile(
            label: habit.name,
            icon: Icons.edit,
            onTap: () async {
              final newName = await showEditNameDialog(
                context,
                currentName: habit.name,
                label: l10n.createActivityNameLabel,
                hint: l10n.createActivityNameHintTask,
                saveButtonLabel: l10n.createActivitySaveButton,
              );
              if (newName != null) {
                bloc.add(HabitNameChangeSubmitted(newName));
              }
            },
          ),
          const _Divider(),
          DetailsActionTile(
            label: l10n.createActivityStartDateLabelTask,
            icon: Icons.today,
            date: habit.startDate,
            onTap: () async {
              final newStartDate = await showDatePicker(
                context: context,
                initialDate: habit.startDate,
                firstDate: DateTime(habit.startDate.year - 1),
                lastDate: lastDate,
              );
              if (newStartDate != null) {
                bloc.add(HabitStartDateChangeSubmitted(newStartDate));
              }
            },
          ),
          const _Divider(),
          DetailsActionTile(
            label: 'End date',
            icon: Icons.today,
            date: habit.endDate,
            onTap: () => pickEndDate(
              context,
              currentDate: habit.endDate,
              firstDate: habit.startDate.add(const Duration(days: 1)),
              preferredInitialDate: habit.endDate ?? DateTime.now(),
              neverLabel: l10n.createActivityEndsNever,
              pickDateLabel: l10n.createActivityEndsOnDate,
              onChanged: (newEndDate) =>
                  bloc.add(HabitEndDateChangeSubmitted(newEndDate)),
            ),
          ),
          const _Divider(),
          DetailsActionTile(
            label: l10n.deleteHabitOrTask,
            icon: Icons.delete,
            onTap: () async {
              final confirmed = await showConfirmationDialog(
                context,
                message: l10n.deleteConfirmationMessage(habit.name),
                yesLabel: l10n.commonYes,
                noLabel: l10n.commonNo,
              );
              if (confirmed) {
                bloc.add(const HabitArchiveRequestSubmitted());
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
