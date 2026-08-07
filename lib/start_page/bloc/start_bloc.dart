import 'package:bloc/bloc.dart';
import 'package:habit_tracker/start_page/bloc/start_event.dart';
import 'package:habit_tracker/start_page/bloc/start_state.dart';
import 'package:habit_tracker/start_page/utils/date_time_x.dart';

/// Manages which day is selected on the start page.
class StartBloc extends Bloc<StartEvent, StartState> {
  /// Creates a [StartBloc], defaulting the selected day to today.
  StartBloc({DateTime? initialDate})
    : super(StartState(selectedDate: initialDate ?? DateTime.now())) {
    on<StartDaySelected>(_onDaySelected);
    on<StartActivitiesLoaded>(_onActivitiesLoaded);
  }

  void _onDaySelected(StartDaySelected event, Emitter<StartState> emit) {
    if (event.date.isSameDayAs(state.selectedDate)) {
      // Re-selecting the day that's already selected (e.g. tapping the
      // app bar's "jump to today" shortcut while today is already
      // selected) — DateTime.now() differs by time-of-day, but it isn't
      // actually a new day, so the loaded activities are still valid.
      emit(state.copyWith(selectedDate: event.date));
      return;
    }
    // The previously loaded activities were for the old selected day, so
    // they're no longer valid. There's no per-day storage yet — once a
    // real data source exists, this is where it'd be asked to load the
    // new day's activities.
    emit(state.copyWith(selectedDate: event.date, activities: const []));
  }

  void _onActivitiesLoaded(
    StartActivitiesLoaded event,
    Emitter<StartState> emit,
  ) {
    emit(state.copyWith(activities: event.activities));
  }
}
