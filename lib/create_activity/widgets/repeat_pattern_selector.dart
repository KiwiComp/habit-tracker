import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habits_repository/habits_repository.dart';

/// A segmented control for choosing whether a habit repeats every day or on
/// specific days.
///
/// Only meaningful for habits — a task's [Frequency] is always
/// [Frequency.once] and never shows this control.
class RepeatPatternSelector extends StatelessWidget {
  /// Creates a [RepeatPatternSelector].
  ///
  /// [selected] must be [Frequency.daily] or [Frequency.weekdays].
  const RepeatPatternSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The currently selected repeat pattern.
  final Frequency selected;

  /// Called when the user picks the other pattern.
  final ValueChanged<Frequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<Frequency>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: context.colorScheme.tertiary,
        selectedForegroundColor: context.extendedColors.onAccent,
      ),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: Frequency.daily,
          label: Text(l10n.createActivityRepeatDaily),
        ),
        ButtonSegment(
          value: Frequency.weekdays,
          label: Text(l10n.createActivityRepeatWeekdays),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
