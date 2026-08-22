/// Which tab of the shell's `StatefulShellRoute.indexedStack` is active.
///
/// Values are ordered to match `buildAppRouter`'s `StatefulShellBranch` list
/// exactly — `navigationShell.currentIndex` indexes into that list
/// positionally, so `ShellBranch.values[navigationShell.currentIndex]` reads
/// off the corresponding value here. Reordering the branches means
/// reordering this enum too.
enum ShellBranch {
  /// The Today tab — `StartPage`, at `/`.
  today,

  /// The Habits tab — `HabitsListPage`, at `/habits`.
  habits,

  /// The Tasks tab — `TasksListPage`, at `/tasks`.
  tasks,
}
