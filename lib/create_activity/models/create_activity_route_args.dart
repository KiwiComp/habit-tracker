import 'package:habit_tracker/create_activity/models/activity_type.dart';
import 'package:meta/meta.dart';

/// The `extra` payload passed to the `/create` route — bundles the two
/// pieces `ShellScaffold` knows at tap time (which sheet option was picked,
/// and which start date applies) into one value, since `GoRouterState.extra`
/// only carries a single object.
@immutable
class CreateActivityRouteArgs {
  /// Creates a [CreateActivityRouteArgs].
  const CreateActivityRouteArgs({required this.type, required this.startDate});

  /// Which option the user tapped in the add-activity sheet.
  final ActivityType type;

  /// The date `CreateActivityBloc` should seed `startDate` with. If null,
  /// CreateActivityState sets startDate to DateTime.now().
  final DateTime? startDate;

  @override
  bool operator ==(Object other) {
    return other is CreateActivityRouteArgs &&
        other.type == type &&
        other.startDate == startDate;
  }

  @override
  int get hashCode => Object.hash(type, startDate);
}
