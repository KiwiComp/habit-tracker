import 'package:meta/meta.dart';

/// A record that a habit happened on a given day.
///
/// The presence of an [Entry] row *is* the completion — there is no
/// `completed` flag on the habit to keep in sync.
@immutable
class Entry {
  /// Creates an [Entry].
  const Entry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.createdAt,
  });

  /// Uniquely identifies this entry.
  final String id;

  /// The habit this entry belongs to.
  final String habitId;

  /// The calendar day this completion belongs to. Local midnight.
  final DateTime date;

  /// When this entry was logged.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entry &&
          other.id == id &&
          other.habitId == habitId &&
          other.date == date;

  @override
  int get hashCode => Object.hash(id, habitId, date);

  @override
  String toString() => 'Entry($habitId on $date)';
}
