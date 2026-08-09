import 'package:bloc/bloc.dart';
import 'package:habit_tracker/create_activity/bloc/create_activity_event.dart';
import 'package:habit_tracker/create_activity/bloc/create_activity_state.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habits_repository/habits_repository.dart';

/// Manages the in-progress form for creating a new habit or task.
class CreateActivityBloc
    extends Bloc<CreateActivityEvent, CreateActivityState> {
  /// Creates a [CreateActivityBloc], seeded with [initialType] — whichever
  /// option the user tapped in the add-activity sheet.
  CreateActivityBloc({required ActivityType initialType})
    : super(
        CreateActivityState(
          activityType: initialType,
          frequency: initialType == ActivityType.task
              ? Frequency.once
              : Frequency.daily,
        ),
      ) {
    on<CreateActivityTypeChanged>(_onTypeChanged);
    on<CreateActivityNameChanged>(_onNameChanged);
    on<CreateActivityRepeatPatternChanged>(_onRepeatPatternChanged);
    on<CreateActivityWeekdayToggled>(_onWeekdayToggled);
    on<CreateActivityStartDateChanged>(_onStartDateChanged);
    on<CreateActivityEndDateChanged>(_onEndDateChanged);
    on<CreateActivitySaveRequested>(_onSaveRequested);
  }

  void _onTypeChanged(
    CreateActivityTypeChanged event,
    Emitter<CreateActivityState> emit,
  ) {
    emit(
      state.copyWith(
        activityType: event.type,
        frequency: event.type == ActivityType.task
            ? Frequency.once
            : Frequency.daily,
        weekdays: const {},
        clearEndDate: true,
      ),
    );
  }

  void _onNameChanged(
    CreateActivityNameChanged event,
    Emitter<CreateActivityState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onRepeatPatternChanged(
    CreateActivityRepeatPatternChanged event,
    Emitter<CreateActivityState> emit,
  ) {
    emit(
      state.copyWith(
        frequency: event.frequency,
        weekdays: event.frequency == Frequency.daily
            ? const {}
            : state.weekdays,
      ),
    );
  }

  void _onWeekdayToggled(
    CreateActivityWeekdayToggled event,
    Emitter<CreateActivityState> emit,
  ) {
    final weekdays = Set<int>.from(state.weekdays);
    if (!weekdays.remove(event.weekday)) {
      weekdays.add(event.weekday);
    }
    emit(state.copyWith(weekdays: weekdays));
  }

  void _onStartDateChanged(
    CreateActivityStartDateChanged event,
    Emitter<CreateActivityState> emit,
  ) {
    emit(state.copyWith(startDate: event.date));
  }

  void _onEndDateChanged(
    CreateActivityEndDateChanged event,
    Emitter<CreateActivityState> emit,
  ) {
    emit(
      state.copyWith(endDate: event.date, clearEndDate: event.date == null),
    );
  }

  void _onSaveRequested(
    CreateActivitySaveRequested event,
    Emitter<CreateActivityState> emit,
  ) {
    if (!state.canSave) return;
    // TODO(you): call HabitsRepository.createHabit(name: state.name,
    // frequency: state.frequency, startDate: state.startDate,
    // weekdays: state.weekdays) once a HabitsRepository is wired into the
    // app (see root TODO.md). Nothing is persisted yet — state already
    // holds everything that call needs. Note createHabit doesn't accept
    // endDate yet either — that's a separate, small addition once wiring
    // actually happens (see root TODO.md).
  }
}
