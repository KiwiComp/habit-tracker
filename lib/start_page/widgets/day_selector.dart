import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/l10n.dart';
import 'package:habit_tracker/start_page/bloc/bloc.dart';
import 'package:habit_tracker/start_page/utils/date_time_x.dart';
import 'package:intl/intl.dart';

/// How many days are shown on either side of today in the day strip.
///
/// A rolling window (rather than a calendar-month bound) so today can
/// always be centered with [_daySpan] days on either side, even when today
/// is near the start or end of a calendar month.
const _daySpan = 45;

/// A horizontally scrollable strip of days, initially centered on today.
class DaySelector extends StatefulWidget {
  /// Creates a [DaySelector].
  const DaySelector({super.key});

  @override
  State<DaySelector> createState() => DaySelectorState();
}

/// State for [DaySelector].
///
/// Public (rather than the usual private `_DaySelectorState`) so a parent
/// can hold a `GlobalKey<DaySelectorState>` and call [scrollToToday]
/// imperatively — e.g. from a "jump back to today" tap elsewhere on the
/// page. This is the same pattern as `GlobalKey<FormState>` and
/// `formKey.currentState!.validate()`.
class DaySelectorState extends State<DaySelector> {
  final GlobalKey _todayKey = GlobalKey();
  late final List<DateTime> _days = _buildDayRange();

  @override
  void initState() {
    super.initState();
    // Center today in the viewport once the strip has laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(scrollToToday(duration: Duration.zero));
    });
  }

  /// Animates the strip so today's chip is centered in the viewport again.
  ///
  /// Uses Scrollable.ensureVisible (rather than computing a pixel offset)
  /// so it works regardless of how wide each chip renders, e.g. under a
  /// larger accessibility text scale.
  Future<void> scrollToToday({
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    final todayContext = _todayKey.currentContext;
    if (todayContext == null) return;
    await Scrollable.ensureVisible(
      todayContext,
      alignment: 0.5,
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  List<DateTime> _buildDayRange() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - _daySpan);
    return List.generate(
      _daySpan * 2 + 1,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = context.select<StartBloc, DateTime>(
      (bloc) => bloc.state.selectedDate,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
      child: Row(
        children: [
          for (var i = 0; i < _days.length; i++) ...[
            if (i > 0) SizedBox(width: context.spacing.sm),
            _DayChip(
              key: i == _daySpan ? _todayKey : null,
              date: _days[i],
              isSelected: _days[i].isSameDayAs(selectedDate),
              onTap: () =>
                  context.read<StartBloc>().add(StartDaySelected(_days[i])),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final backgroundColor = isSelected
        // ? context.extendedColors.accent
        ? context.colorScheme.tertiary
        // : context.colorScheme.surfaceContainerHigh;
        : context.colorScheme.surfaceContainerHigh;
    final foregroundColor = isSelected
        ? context.extendedColors.onAccent
        : context.colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(context.radius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius.lg),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.sm,
            vertical: context.spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _capitalize(DateFormat.E(locale).format(date)),
                style: AppTextStyle.labelSmall.copyWith(
                  color: foregroundColor,
                ),
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                DateFormat('d MMM', locale).format(date),
                style: AppTextStyle.labelMedium.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CLDR's abbreviated weekday names are lowercase in some locales (e.g.
/// Swedish "mån"), unlike English/Spanish — capitalize for a consistent
/// look across locales.
String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
