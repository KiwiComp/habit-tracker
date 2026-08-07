import 'package:bloc/bloc.dart';
import 'package:habit_tracker/add_activity/bloc/add_activity_event.dart';
import 'package:habit_tracker/add_activity/bloc/add_activity_state.dart';
import 'package:habit_tracker/add_activity/models/models.dart';

/// Tracks which activity type has been tapped in the add-activity sheet.
class AddActivityBloc extends Bloc<AddActivityEvent, AddActivityState> {
  /// Creates an [AddActivityBloc].
  AddActivityBloc() : super(const AddActivityState()) {
    on<AddActivityHabitTapped>(_onHabitTapped);
    on<AddActivityTaskTapped>(_onTaskTapped);
  }

  void _onHabitTapped(
    AddActivityHabitTapped event,
    Emitter<AddActivityState> emit,
  ) {
    emit(state.copyWith(selectedType: ActivityType.habit));
  }

  void _onTaskTapped(
    AddActivityTaskTapped event,
    Emitter<AddActivityState> emit,
  ) {
    emit(state.copyWith(selectedType: ActivityType.task));
  }
}
