import 'package:bloc/bloc.dart';
import 'package:habit_tracker/create_activity/bloc/create_activity_event.dart';
import 'package:habit_tracker/create_activity/bloc/create_activity_state.dart';
import 'package:habit_tracker/create_activity/models/models.dart';
import 'package:habits_repository/habits_repository.dart';

/// Manages the in-progress form for creating a new habit or task.
class CreateActivityBloc
    extends Bloc<CreateActivityEvent, CreateActivityState> {
  /// Creates a [CreateActivityBloc], seeded with [initialType] — whichever
  /// option the user tapped in the add-activity sheet. The
  /// `habitsRepository` argument persists the activity once
  /// `CreateActivitySaveRequested` fires.
  CreateActivityBloc({
    required ActivityType initialType,
    required this._habitsRepository,
  }) : super(
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

  final HabitsRepository _habitsRepository;

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

  Future<void> _onSaveRequested(
    CreateActivitySaveRequested event,
    Emitter<CreateActivityState> emit,
  ) async {
    if (!state.canSave) return;
    emit(state.copyWith(status: CreateActivitySaveStatus.saving));
    try {
      await _habitsRepository.createHabit(
        name: state.name,
        frequency: state.frequency,
        startDate: state.startDate,
        weekdays: state.weekdays,
        endDate: state.endDate,
      );
      emit(state.copyWith(status: CreateActivitySaveStatus.success));
    } on Exception catch (error, stackTrace) {
      // Reported through the existing BlocObserver.onError logging (see
      // AppBlocObserver) rather than rethrown, so the bloc keeps working —
      // emitting failure below resets the form to retry instead of leaving
      // it stuck showing a spinner.
      addError(error, stackTrace);
      emit(state.copyWith(status: CreateActivitySaveStatus.failure));
      emit(state.copyWith(status: CreateActivitySaveStatus.idle));
    }
  }
}
