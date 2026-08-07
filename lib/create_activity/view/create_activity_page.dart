import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/add_activity/models/models.dart';
import 'package:habit_tracker/create_activity/bloc/bloc.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createActivityAppBarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ActivityTypeToggle(
                selected: state.activityType,
                onChanged: (type) => bloc.add(CreateActivityTypeChanged(type)),
              ),
              SizedBox(height: context.spacing.lg),
              TextField(
                onChanged: (name) => bloc.add(CreateActivityNameChanged(name)),
                decoration: InputDecoration(
                  labelText: l10n.createActivityNameLabel,
                  hintText: isHabit
                      ? l10n.createActivityNameHintHabit
                      : l10n.createActivityNameHintTask,
                ),
              ),
              SizedBox(height: context.spacing.lg),
              if (isHabit) ...[
                Text(
                  l10n.createActivityRepeatLabel,
                  style: AppTextStyle.titleSmall,
                ),
                SizedBox(height: context.spacing.sm),
                RepeatPatternSelector(
                  selected: state.frequency,
                  onChanged: (frequency) =>
                      bloc.add(CreateActivityRepeatPatternChanged(frequency)),
                ),
                if (state.frequency == Frequency.weekdays) ...[
                  SizedBox(height: context.spacing.md),
                  WeekdayChipRow(
                    selected: state.weekdays,
                    onToggled: (weekday) =>
                        bloc.add(CreateActivityWeekdayToggled(weekday)),
                  ),
                ],
                SizedBox(height: context.spacing.lg),
              ],
              StartDateField(
                label: isHabit
                    ? l10n.createActivityStartDateLabelHabit
                    : l10n.createActivityStartDateLabelTask,
                date: state.startDate,
                onChanged: (date) =>
                    bloc.add(CreateActivityStartDateChanged(date)),
              ),
              SizedBox(height: context.spacing.xl),
              AppButton.primary(
                onPressed: state.canSave
                    ? () => bloc.add(const CreateActivitySaveRequested())
                    : null,
                child: Text(l10n.createActivitySaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
