import 'package:habit_tracker/add_activity/models/models.dart';
import 'package:meta/meta.dart';

/// The state of `AddActivityBloc`.
@immutable
final class AddActivityState {
  /// Creates an [AddActivityState].
  const AddActivityState({this.selectedType});

  /// The activity type most recently tapped in the sheet, if any.
  ///
  /// Nothing consumes this yet — there's no habit/task creation flow to
  /// hand off to (see root `TODO.md`). It exists so the tap has somewhere
  /// to go once that flow is built.
  final ActivityType? selectedType;

  /// Returns a copy of this state with the given fields replaced.
  AddActivityState copyWith({ActivityType? selectedType}) {
    return AddActivityState(selectedType: selectedType ?? this.selectedType);
  }

  @override
  bool operator ==(Object other) {
    return other is AddActivityState && other.selectedType == selectedType;
  }

  @override
  int get hashCode => selectedType.hashCode;
}
