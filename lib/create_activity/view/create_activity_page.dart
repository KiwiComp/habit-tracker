import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/create_activity/bloc/bloc.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habit_tracker/create_activity/widgets/widgets.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habits_repository/habits_repository.dart';

/// The page for creating a new habit or task.
///
/// One form for both (per the app's "Option 1" decision) — an
/// [ActivityTypeToggle] switches which fields are relevant, rather than two
/// separate screens. `packages/habits_repository`'s `Habit` already models
/// both as the same entity, differing only by `Frequency`, so the form
/// follows that shape.
class CreateActivityPage extends StatelessWidget {
  /// Creates a [CreateActivityPage], seeded with [initialType].
  const CreateActivityPage({required this.initialType, super.key});

  /// Which option the user tapped in the add-activity sheet to get here.
  final ActivityType initialType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateActivityBloc(initialType: initialType),
      child: const _CreateActivityView(),
    );
  }
}

class _CreateActivityView extends StatelessWidget {
  const _CreateActivityView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CreateActivityBloc>().state;
    final bloc = context.read<CreateActivityBloc>();
    final isHabit = state.activityType == ActivityType.habit;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createActivityAppBarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            spacing: spacing.lg,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                spacing: spacing.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(text: 'Type'), //TODO(k): l10n
                  ActivityTypeToggle(
                    selected: state.activityType,
                    onChanged: (type) =>
                        bloc.add(CreateActivityTypeChanged(type)),
                  ),
                ],
              ),
              Column(
                spacing: spacing.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(text: 'Name'), //TODO(k): l10n
                  AppTextField(
                    onChanged: (name) =>
                        bloc.add(CreateActivityNameChanged(name)),
                    label: l10n.createActivityNameLabel,
                    hint: isHabit
                        ? l10n.createActivityNameHintHabit
                        : l10n.createActivityNameHintTask,
                  ),
                ],
              ),

              if (isHabit) ...[
                Column(
                  spacing: spacing.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(text: l10n.createActivityRepeatLabel),
                    RepeatPatternSelector(
                      selected: state.frequency,
                      onChanged: (frequency) => bloc.add(
                        CreateActivityRepeatPatternChanged(frequency),
                      ),
                    ),
                    if (state.frequency == Frequency.weekdays) ...[
                      SizedBox(height: context.spacing.md),
                      WeekdayChipRow(
                        selected: state.weekdays,
                        onToggled: (weekday) =>
                            bloc.add(CreateActivityWeekdayToggled(weekday)),
                      ),
                    ],
                  ],
                ),
              ],
              Column(
                spacing: spacing.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(text: 'Starts on'), // TODO(k): l10n
                  StartDateField(
                    label: isHabit
                        ? l10n.createActivityStartDateLabelHabit
                        : l10n.createActivityStartDateLabelTask,
                    date: state.startDate,
                    onChanged: (date) =>
                        bloc.add(CreateActivityStartDateChanged(date)),
                  ),
                ],
              ),
              if (isHabit) ...[
                Column(
                  spacing: spacing.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(text: l10n.createActivityEndsLabel),
                    EndDateField(
                      date: state.endDate,
                      firstDate: state.startDate,
                      onChanged: (date) =>
                          bloc.add(CreateActivityEndDateChanged(date)),
                    ),
                    if (state.hasUnreachableWeekdayWindow)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: context.iconSize.sm,
                            color: context.colorScheme.error,
                          ),
                          SizedBox(width: spacing.xs),
                          Expanded(
                            child: Text(
                              l10n.createActivityWeekdayWindowWarning,
                              style: AppTextStyle.bodySmall.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(context.spacing.md),
        child: AppButton.primary(
          onPressed: state.canSave
              ? () => bloc.add(const CreateActivitySaveRequested())
              : null,
          child: Text(l10n.createActivitySaveButton),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyle.titleMedium;

    return Text(
      text,
      style: titleStyle,
    );
  }
}
